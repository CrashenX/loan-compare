#!/usr/bin/perl
use warnings FATAL => 'all';
use strict;
use Getopt::Long;
use lib "../lib/";
use Finance::Amortization;

my $options = GetOptions (
    "t|tax"          => \(my $use_tax=0),
    "f|roll-fees-in" => \(my $fees_in=0),
    "h|help"         => \(my $help=0)
);

my $compounding = 12;

my $amount = 170000;
my $percent_down = 5;
my $allot = 2487.60;
my $init_allot = 8500;
my $fees = 2826.25;
my $earn_rate = 0.07 / $compounding;
my $years = 19;

my $cash2table = $amount * $percent_down/100;
my $periods = $compounding * $years;

$amount *= (1 - $percent_down/100);
($fees_in) ? ($amount += $fees) : ($cash2table += $fees);
$init_allot -= $cash2table;

die("Insufficient initial funds") if(0 > $init_allot);

my $invest = $init_allot;

my $am = new Finance::Amortization(
    principal => $amount,
    rate => 0.0375,
    tax_rate => 0.28,
    periods => 360,
    compounding => $compounding,
    precision => 2
);

my $schedule = $am->schedule();
my $payments = @$schedule;
my $period   = 0;

for($period = 0; $period < $periods; ++$period) {
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

printf("Loan  Amount: %10.*f\n", $am->{'precision'},       $amount);
printf("Percent Down: %10.*f\n", $am->{'precision'}, $percent_down);
printf("Cash 2 Table: %10.*f\n", $am->{'precision'},   $cash2table);
printf("Finance Fees: %10.*f\n", $am->{'precision'},         $fees);
printf("Start  Value: %10.*f\n", $am->{'precision'},   $init_allot);

my $balance = $schedule->[$period-1]->{'balance'};
printf("Future Value: %10.*f\n", $am->{'precision'},       $invest);
printf("Loan Balance: %10.*f\n", $am->{'precision'},      $balance);
if($period <= $payments) {
    $invest -= $balance;
}
printf("Adjusted  FV: %10.*f\n", $am->{'precision'},       $invest);

#$am->print_schedule();
