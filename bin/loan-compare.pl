#!/usr/bin/perl
use warnings FATAL => 'all';
use strict;
use Getopt::Long;
use File::Slurp;
use lib "../lib/";
use Finance::Amortization;

my $COMPOUNDING = 12;

my $options = GetOptions (
    "t|tax"          => \(my $use_tax=0),
    "r|roll-fees-in" => \(my $fees_in=0),
    "f|file=s"       => \(my $file="loans.txt"),
    "h|help"         => \(my $help=0)
);

sub parse_file()
{
    my $fees_in = shift;
    my $scenarios = ();

    my @lines = read_file($file);
    for my $line (@lines) {
        chomp($line);
        next if(substr($line,0,1) eq "#");
        if($line !~ m/[^|]+|([0-9.]+|){7}[0-9]+|[0-9]+$/) {
            printf("Invalid input line ('%s'); skipping\n", $line);
            next;
        }

        my ($n,$l,$i,$a,$f,$d,$r,$e,$t,$m) = split(/\|/,$line);
        my $s = {
            name          => $n,
            loan_amount   => $l * (1 - $d/100),
            init_allot    => $i,
            allot         => $a,
            fees          => $f,
            loan_rate     => $r/100,
            earn_rate     => $e/100 / $COMPOUNDING,
            cash2table    => $l * $d/100,
            loan_term     => $t,
            periods       => $m
        };

        if($fees_in) {
            $s->{'loan_amount'} += $f;
        }
        else {
            $s->{'cash2table'} += $f;
        }
        $s->{'init_allot'} -= $s->{'cash2table'};

        if(0 > $s->{'init_allot'}) {
            printf("Insufficient initial funds for '%s'; skipping\n",
                $s->{'name'});
            next;
        }
        push(@$scenarios, $s);
    }
    return $scenarios;
}


sub calculate_fv()
{
    my $fv        = shift;
    my $periods   = shift;
    my $rate      = shift;
    my $allot     = shift;
    my $precision = shift;
    my $schedule  = shift;
    my $payments  = @$schedule;
    my $period    = 0;

    for($period = 0; $period < $periods; ++$period) {
        my $subtract = 0;
        my $sp = $schedule->[$period];

        if($period < $payments) {
            my $p = $sp->{'principal'};
            my $i = $sp->{'interest'};
            my $t = ($use_tax) ? $sp->{'tax_savings'} : 0;

            $subtract += ($p + $i - $t);
            die() if(0 > $subtract);
        }

        $fv *= ($rate + 1);
        $fv += $allot;
        $fv -= $subtract;
    }

    return $fv;
}

sub print_results()
{
    my $scenario  = shift;
    my $fv        = shift;
    my $balance   = shift;
    my $precision = shift;

    #$am->print_schedule();

    printf("%s\n------------------------\n", $scenario->{'name'});
    printf("Loan  Amount: %10.*f\n", $precision, $scenario->{'loan_amount'});
    printf("Cash 2 Table: %10.*f\n", $precision, $scenario->{'cash2table'});
    printf("Finance Fees: %10.*f\n", $precision, $scenario->{'fees'});
    printf("Start  Value: %10.*f\n", $precision, $scenario->{'init_allot'});
    printf("Future Value: %10.*f\n", $precision, $fv);
    printf("Loan Balance: %10.*f\n", $precision, $balance);
    $fv -= $balance;
    printf("Adjusted  FV: %10.*f\n", $precision, $fv);
    printf("\n");
}

sub main()
{
    my $scenarios = &parse_file($fees_in);

    if(1 > @$scenarios) {
        print("No valid loan scenarios to compare; exiting\n");
        exit 1;
    }

    for my $s (@$scenarios) {
        my $am = new Finance::Amortization(
            principal => $s->{'loan_amount'},
            rate => $s->{'loan_rate'},
            tax_rate => 0.28,
            periods => $s->{'loan_term'},
            compounding => $COMPOUNDING,
            precision => 2
        );

        my $schedule  = $am->schedule();
        my $precision = $am->{'precision'};
        my $periods   = $s->{'periods'};
        my $balance   = $periods <= @$schedule ?
                                        $schedule->[$periods-1]->{'balance'} :
                                        0;

        my $fv = &calculate_fv($s->{'init_allot'},
                               $periods,
                               $s->{'earn_rate'},
                               $s->{'allot'},
                               $precision,
                               $schedule);

        &print_results($s, $fv, $balance, $precision);
    }
}

&main();
