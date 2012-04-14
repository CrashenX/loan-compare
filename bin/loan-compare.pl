#!/usr/bin/perl
use warnings FATAL => 'all';
use strict;
use lib "../lib/";
use Finance::Amortization;

print "hello world\n";

my $amortization = new Finance::Amortization(
    principal => 165000,
    rate => 0.04,
    periods => 360,
    compounding => 12,
    precision => 2
);

my $period = 1;

my $principal = $amortization->principal();
my $rate = $amortization->rate();
my $balance = $amortization->balance($period);
my $balance_old = $amortization->balance_old($period);
my $interest = $amortization->interest($period);
my $interest_old = $amortization->interest_old($period);
my $total_interest = $amortization->total_interest($period);
my $periods = $amortization->periods();
my $payment = $amortization->payment();

print "Payment: $payment\n";
print "Periods: $periods\n";
print "Principal: $principal\n";
print "Rate: $rate\n";
print "Interest Paid: $interest_old $interest\n";
print "Total Interest Paid: $total_interest\n";
print "Balance: $balance_old $balance\n";

#$amortization->print_schedule();
