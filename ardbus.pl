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
my $object = MyObj->new($service);
my $reactor = Net::DBus::Reactor->main();

$reactor->add_read(fileno(F), Net::DBus::Callback->new(method => sub { 
    my $readie="";
    sysread F, $readie, 40;
    #printf STDOUT $readie;
}, args => []));

$reactor->run();
