#!/usr/bin/perl
#
#Scom 7330 time update script by Sean Smith VE6SAR
#http://ve6sar.northernsmiths.ca
#
#MIT License
#
#Copyright (c) 2017 ve6sar
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

use strict;
use POSIX qw(strftime);
use Time::HiRes qw(usleep);

my $serialPort = "/dev/ttyUSB1"; #Our serial port Windows format is com1
my $PW = "99"; #The master password for the controller 
my $d = 50000; #Set the character send delay in micro seconds Scom recommends 50ms = 50000us

# For Linux
use Device::SerialPort;
my $port = Device::SerialPort->new($serialPort);

# For Windows. You only need one or the other.
# Uncomment these for Windows and comment out above
#use Win32::SerialPort;
#my $port = Win32::SerialPort->new($serialPort);

print "Scom 7330 time update script by Sean Smith VE6SAR\n\r";

$port->baudrate(57600); # Configure this to match your device
$port->databits(8);
$port->parity("none");
$port->stopbits(1);

my $ts = strftime("%y %m %d %w %H %M %S", localtime(time));
print "Updating to the current Date and Time\r\n";

my $command = "$PW 25 $ts *\r";

#Send to the controller 1 charactor at a time to keep from overflowing the buffer
foreach my $char (split //, $command) {
$port->write($char);
usleep($d); #sleep to allow the controller time to process each charactor
}
sleep 2;

my $response; #The variable to hold the respose from the controller
my ( $blocking_flags, $in_bytes, $out_bytes, $latch_error_flags ) = $port->status() ;

$port->lookclear; #clear the buffer 
sleep (1) ;
 
# Make sure we got a response and display it  
if( $in_bytes > 0 )
{
    for( my $i = 0 ; $i < $in_bytes ; $i++ )
    {
            # Get a byte at a time to process.
            $response .= $port->read( 1 ) ;

            if( $response =~ /\r/ )
            {
               my $complete = 1 ;
            }
         }
      }

print ("Response is:\n $response\n") ;

$port->close || die "failed to close";
undef $port;                               # frees memory back
