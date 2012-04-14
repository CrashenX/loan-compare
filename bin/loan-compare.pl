#!/usr/bin/perl
use warnings FATAL => 'all';
use strict;
use lib "../lib/";
use Finance::Amortization;

my $compounding = 12;
my $years = 19;
my $periods = $compounding * $years;

my $am1 = new Finance::Amortization(
    principal => 165000,
    rate => 0.04,
    tax_rate => 0.28,
    periods => 360,
    compounding => $compounding,
    precision => 2
);

for(my $i = 0; $i < $period; ++$i) {

}

#my $principal = $amortization->principal();
#my $rate = $amortization->rate();
#my $balance = $amortization->balance($periods);
#my $balance_old = $amortization->balance_old($periods);
#my $interest = $amortization->interest($periods);
#my $interest_old = $amortization->interest_old($periods);
#my $total_interest = $amortization->total_interest($periods);
#my $periods = $amortization->periods();
#my $payment = $amortization->payment();
#
#print "Payment: $payment\n";
#print "Periods: $periods\n";
#print "Principal: $principal\n";
#print "Rate: $rate\n";
#print "Interest Paid: $interest_old $interest\n";
#print "Total Interest Paid: $total_interest\n";
#print "Balance: $balance_old $balance\n";

$amortization->print_schedule();
