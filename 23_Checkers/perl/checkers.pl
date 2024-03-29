#!/usr/bin/perl

# Checkers program in Perl
#   Started with checkers.annotated.bas
# Translated by Kevin Brannen (kbrannen)

use strict;
use warnings;

# globals
#
# The current move: (rating, current x, current y, new x, new y)
# 'rating' represents how good the move is; higher is better.
my @ratings = (-99); # (4); # Start with minimum score
# The board.  Pieces are represented by numeric values:
#
#      - 0     = empty square
#      - -1,-2 = X (-1 for regular piece, -2 for king)
#      - 1,2   = O (1 for regular piece, 2 for king)
#
# This program's player ("me") plays X.
my @board; # (7,7)
# chars to print for the board, add 2 to the board value as an index to the char
my @chars = ("X*", "X", ".", "O", "O*");
my $neg1 = -1;          # constant holding -1
my $winner = "";
my $upgrade = shift(@ARGV) // "";
$upgrade = $upgrade eq "-o" ? 0 : 1;

#####

print "\n";
print " " x 32, "CHECKERS\n";
print " " x 15, "CREATIVE COMPUTING  MORRISTOWN, NEW JERSEY\n\n\n";


print "THIS IS THE GAME OF CHECKERS.  THE COMPUTER IS X,\n";
print "AND YOU ARE O.  THE COMPUTER WILL MOVE FIRST.\n";
print "SQUARES ARE REFERRED TO BY A COORDINATE SYSTEM.\n";
print "(0,0) IS THE LOWER LEFT CORNER\n";
print "(0,7) IS THE UPPER LEFT CORNER\n";
print "(7,0) IS THE LOWER RIGHT CORNER\n";
print "(7,7) IS THE UPPER RIGHT CORNER\n";
print "THE COMPUTER WILL TYPE '+TO' WHEN YOU HAVE ANOTHER\n";
print "JUMP.  TYPE TWO NEGATIVE NUMBERS IF YOU CANNOT JUMP.\n";
print "ENTER YOUR MOVE POSITION LIKE '0 0' OR '0,0'.\n\n\n";

# Initialize the board.  Data is 2 length-wise strips repeated.
my @data = ();
for (1 .. 32) { push(@data, (1,0,1,0,0,0,-1,0, 0,1,0,0,0,-1,0,-1)); }
for my $x (0 .. 7)
{
    for my $y (0 .. 7)
    {
        $board[$x][$y] = shift(@data);
    }
}

# Start of game loop.  First, my turn.
while (1)
{

    # For each square on the board, search for one of my pieces
    # and if it can make the best move so far, store that move in 'r'
    for my $x (0 .. 7)
    {
        for my $y (0 .. 7)
        {
            # Skip if this is empty or an opponent's piece
            next if ($board[$x][$y] > -1);

            # If this is one of my ordinary pieces, analyze possible
            # forward moves.
            if ($board[$x][$y] == -1)
            {
                for (my $a = -1 ; $a <= 1 ; $a +=2)
                {
                    $b = $neg1;
                    find_move($x, $y, $a, $b);
                }
            }

            # If this is one of my kings, analyze possible forward
            # and backward moves.
            if ($board[$x][$y] == -2)
            {
                for (my $a = -1 ; $a <= 1 ; $a += 2)
                {
                    for (my $b = -1 ; $a <= 1 ; $b += 2) { find_move($x, $y, $a, $b); }
                }
            }
        }
    }


    if ($ratings[0] == -99) # Game is lost if no move could be found.
    {
        $winner = "you";
        last;
    }

    # Print the computer's move.  (Note: chr$(30) is an ASCII RS
    # (record separator) code; probably no longer relevant.)
    print "FROM $ratings[1],$ratings[2] TO $ratings[3],$ratings[4] ";
    $ratings[0] = -99;

    # Make the computer's move.  If the piece finds its way to the
    # end of the board, crown it.
    LOOP1240: {
        if ($ratings[4] == 0)
        {
            $board[$ratings[3]][$ratings[4]] = -2;
            last LOOP1240;
        }
        $board[$ratings[3]][$ratings[4]] = $board[$ratings[1]][$ratings[2]];
        $board[$ratings[1]][$ratings[2]] = 0;

        # If the piece has jumped 2 squares, it means the computer has
        # taken an opponents' piece.
        if (abs($ratings[1] - $ratings[3]) == 2)
        {
            $board [($ratings[1]+$ratings[3])/2] [($ratings[2]+$ratings[4])/2] = 0;     # Delete the opponent's piece

            # See if we can jump again.  Evaluate all possible moves.
            my $x = $ratings[3];
            my $y = $ratings[4];
            for (my $a = -2 ; $a <= 2 ; $a += 4)
            {
                if ($board[$x][$y] == -1)
                {
                    $b = -2;
                    eval_move($x, $y, $a, $b);
                }
                if ($board[$x][$y] == -2)
                {
                    for (my $b = -2 ; $b <= 2 ; $b += 4) { eval_move($x, $y, $a, $b); }
                }
            }

            # If we've found a move, go back and make that one as well
            if ($ratings[0] != -99)
            {
                print "TO $ratings[3], $ratings[4] ";
                $ratings[0] = -99;
                next LOOP1240;
            }
        }
    } # LOOP1240

    # Now, print the board
    print "\n\n\n";
    for (my $y = 7 ; $y >= 0 ; $y--)
    {
        my $line = "";
        $line = "$y|" if ($upgrade);
        for my $x (0 .. 7)
        {
            my $c = $chars[$board[$x][$y] + 2];
            $c = ' ' if ($upgrade && (($y % 2 == 0 && $x % 2 == 1) || ($y % 2 == 1 && $x % 2 == 0)));
            $line = tab($line, 5*$x+7, $c);
        }
        print $line;
        print " \n\n";
    }
    print "       _    _    _    _    _    _    _    _\n" if ($upgrade);
    print "       0    1    2    3    4    5    6    7\n" if ($upgrade);
    print "\n";

    # Check if either player is out of pieces.  If so, announce the
    # winner.
    my ($z, $t) = (0, 0);
    for my $x (0 .. 7)
    {
        for my $y (0 .. 7)
        {
            if ($board[$x][$y] == 1  || $board[$x][$y] == 2)  { $z = 1; }
            if ($board[$x][$y] == -1 || $board[$x][$y] == -2) { $t = 1; }
        }
    }
    if ($z != 1) { $winner = "comp"; last; }
    if ($t != 1) { $winner = "you"; last; }

    # Prompt the player for their move.
    ($z, $t) = (0, 0);
    my ($x, $y, $e, $h, $a, $b);
    do {
        ($e,$h) = get_pos("FROM:");
        $x = $e;
        $y = $h;
    } while ($board[$x][$y] <= 0);
    do {
        ($a,$b) = get_pos("TO:");
        $x = $a;
        $y = $b;
    } while (!($board[$x][$y] == 0 && abs($a-$e) <= 2 && abs($a-$e) == abs($b-$h)));

    LOOP1750: {
        # Make the move and stop unless it might be a jump.
        $board[$a][$b] = $board[$e][$h];
        $board[$e][$h] = 0;
        if (abs($e-$a) != 2) { last LOOP1750; }

        # Remove the piece jumped over
        $board[($e+$a)/2][($h+$b)/2] = 0;

        # Prompt for another move; -1 means player can't, so I've won.
        # Keep prompting until there's a valid move or the player gives
        # up.
        my ($a1, $b1);
        do {
            ($a1,$b1) = get_pos("+TO:");
            if ($a1 < 0) { last LOOP1750; }
        } while ($board[$a1][$b1] != 0 || abs($a1-$a) != 2 || abs($b1-$b) != 2);

        # Update the move variables to correspond to the next jump
        $e = $a;
        $h = $b;
        $a = $a1;
        $b = $b1;
    }

    # If the player has reached the end of the board, crown this piece
    if ($b == 7) { $board[$a][$b] = 2; }

    # And play the next turn.
}

# Endgame:
print "\n", ($winner eq "you" ? "YOU" : "I"), " WIN\n";
exit(0);

###########################################

# make sure we get a 2 value position
sub get_pos
{
    my $prompt = shift;
    my ($p1, $p2);
    do {
        print "$prompt ";
        chomp(my $ans = <>);
        ($p1,$p2) = split(/[, ]/, $ans);
    } while (!defined($p1) || !defined($p2) || $p1 < -1 || $p2 < -1 || $p1 > 7 || $p2 > 7);
    return ($p1,$p2);
}

# deal with basic's tab() for line positioning
#   line = line string we're starting with
#   pos = position to start writing
#   s = string to write
# returns the resultant string, which might not have been changed
sub tab
{
    my ($line, $pos, $str) = @_;
    my $len = length($line);
    # if curser is past position, do nothing
    if ($len <= $pos) { $line .= " " x ($pos - $len) . $str; }
    return $line;
}

# Analyze a move from (x,y) to (x+a, y+b) and schedule it if it's
# the best candidate so far.
sub find_move
{
    my ($x, $y, $a, $b) = @_;
    my $u = $x+$a;
    my $v = $y+$b;

    # Done if it's off the board
    return if ($u < 0 || $u > 7 || $v < 0 || $ v> 7);

    # Consider the destination if it's empty
    eval_jump($x, $y, $u, $v) if ($board[$u][$v] == 0);

    # If it's got an opponent's piece, jump it instead
    if ($board[$u][$v] > 0)
    {

        # Restore u and v, then return if it's off the board
        $u += $a;
        $v += $b;
        return if ($u < 0 || $v < 0 || $u > 7 || $v > 7);

        # Otherwise, consider u,v
        eval_jump($x, $y, $u, $v) if ($board[$u][$v] == 0);
    }
}

# Evaluate jumping (x,y) to (u,v).
#
# Computes a score for the proposed move and if it's higher
# than the best-so-far move, uses that instead by storing it
# and its score in @ratings.
sub eval_jump
{
    my ($x, $y, $u, $v) = @_;

    # q is the score; it starts at 0
    my $q = 0;

    # +2 if it promotes this piece
    $q += 2 if ($v == 0 && $board[$x][$y] == -1);

    # +5 if it takes an opponent's piece
    $q += 5 if (abs($y-$v) == 2);

    # -2 if the piece is moving away from the top boundary
    $q -= 2 if ($y == 7);

    # +1 for putting the piece against a vertical boundary
    $q++ if ($u == 0 || $u == 7);

    for (my $c = -1 ; $c <= 1 ; $c += 2)
    {
        next if ($u+$c < 0 || $u+$c > 7 || $v+$neg1 < 0);

        # +1 for each adjacent friendly piece
        if ($board[$u+$c][$v+$neg1] < 0)
        {
            $q++;
            next;
        }

        # Prevent out-of-bounds testing
        next if ($u-$c < 0 || $u-$c > 7 || $v-$neg1 > 7);

        # -2 for each opponent piece that can now take this piece here
        $q -= 2 if ($board[$u+$c][$v+$neg1] > 0 && ($board[$u-$c][$v-$neg1] == 0 || ($u-$c == $x && $v-$neg1 == $y)));
    }

    # Use this move if it's better than the previous best
    if ($q > $ratings[0])
    {
        $ratings[0] = $q;
        $ratings[1] = $x;
        $ratings[2] = $y;
        $ratings[3] = $u;
        $ratings[4] = $v;
    }
}

# If (u,v) is in the bounds, evaluate it as a move using
# the sub at 910, so storing eval in @ratings.
sub eval_move
{
    my ($x, $y, $a, $b) = @_;
    my $u = $x+$a;
    my $v = $y+$b;
    return if ($u < 0 || $u > 7 || $v < 0 || $v > 7);
    eval_jump($x, $y, $u, $v) if ($board[$u][$v] == 0 && $board[$x+$a/2][$y+$b/2] > 0);
}
