#!/usr/bin/perl
use warnings FATAL => 'all';
use strict;
use Getopt::Long;
use lib "../lib/";
use Finance::Amortization;

my $options = GetOptions (
    "t|tax"    => \(my $use_tax=0),
    "h|help"   => \(my $help=0)
);

my $compounding = 12;
my $years = 19;
my $periods = $compounding * $years;
my $earn_rate = 0.07 / $compounding;
my $initial_investment = 0;
my $allot = 3000;

my $am1 = new Finance::Amortization(
    principal => 165000,
    rate => 0.04,
    tax_rate => 0.28,
    periods => 360,
    compounding => $compounding,
    precision => 2
);

my $schedule = $am1->schedule();
my $payments = @$schedule;
my $invest   = $initial_investment;
for(my $period = 0; $period < $periods; ++$period) {
    my $subtract = 0;

    if($period < $payments) {
        my $p = $schedule->[$period]->{'principal'};
        my $i = $schedule->[$period]->{'interest'};
        my $t = ($use_tax) ? $schedule->[$period]->{'tax_savings'} : 0;

        $subtract += ($p + $i - $t);
        die() if(0 > $subtract);
    }

    $invest *= ($earn_rate+1);
    $invest += $allot;
    $invest -= $subtract;
}

printf("Future Value: %.*f\n", $am1->{'precision'}, $invest);

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

#$amortization->print_schedule();
