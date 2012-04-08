#!/usr/bin/perl -w

# Simple Arduino D-Bus interface. Not for any high-performance things.



use strict;
package MyObj;
use Net::DBus::Exporter qw(org.vi_server.ardbus);
use base qw(Net::DBus::Object);

our $MASKED_PINS=2;
our $DIGITAL_PIN_COUNT=14;

my $lpc = $DIGITAL_PIN_COUNT-$MASKED_PINS; # logical pin count

our $digitalWriteValues="0"x$lpc;
our $digitalReadValues="0"x$lpc;
our $pinModeValues="0"x$lpc;


sub new {
    my $class = shift;
    my $service = shift;
    my $self = $class->SUPER::new($service, '/');
    bless $self, $class;

    return $self;
}

dbus_method("DigitalWrite", ["byte", "bool"]);
dbus_method("PinMode", ["byte", "bool"]);
dbus_signal("DigitalInputChanged", ["byte", "bool"]);

sub DigitalWrite($$) {
    my $self = shift;
    my $pin = shift;
    my $val = shift;
    
    $pin-=$MASKED_PINS;
    return unless ($pin >= 0) && ($pin < $lpc);
    substr($digitalWriteValues, $pin, 1) = ($val ? '1' : '0');
    print "ArDi".$digitalWriteValues."\n";
}

sub PinMode($$) {
    my $self = shift;
    my $pin = shift;
    my $val = shift;
    
    $pin-=$MASKED_PINS;
    return unless ($pin >= 0) && ($pin < $lpc);
    substr($pinModeValues, $pin, 1) = ($val ? '1' : '0');
    print "ArMo".$pinModeValues."\n";
}

sub digitalInputFromArduino($$) {
    my $self = shift;
    my $string = shift;

    my ($i,$j);

    return unless length($string) == 4+$lpc;

    for($i=0, $j=4; $i<$lpc; ++$i, ++$j) {
        my $n = substr($string,            $j, 1);
        my $o = substr($digitalReadValues, $i, 1);
        unless($n eq $o) {
            substr($digitalReadValues, $i, 1) = $n;
            $self->emit_signal("DigitalInputChanged", $i+$MASKED_PINS, not($n eq "0"));
        }
    }
}


package main;
use Net::DBus;
use Net::DBus::Reactor;


system("stty -F /dev/ttyACM0 115200 raw");
open F, "+>", "/dev/ttyACM0" or die("Unable to open /dev/ttyACM0. Edit the source code to tweak it.");
#open F, ">", "/dev/stdout";
select F;
$|=1;


my $bus = Net::DBus->session;
my $service = $bus->export_service("org.vi_server.ardbus");
our $object = MyObj->new($service);
my $reactor = Net::DBus::Reactor->main();

$reactor->add_read(fileno(F), Net::DBus::Callback->new(method => sub { 
    my $readie="";
    sysread F, $readie, 40;
    $object->digitalInputFromArduino($1) if $readie =~ /(ArDi[01]+)\n/;
}, args => []));

$reactor->run();
