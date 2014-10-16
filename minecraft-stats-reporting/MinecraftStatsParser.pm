package MinecraftStatsParser;

use strict;
use 5.010;
use LWP::UserAgent;
use HTML::TableExtract;

# Mapping of interesting block IDs to names
my %block_name_by_id = (
    56 => 'diamond',
    14 => 'gold',
    15 => 'iron',
    13 => 'cobble',
    1  => 'stone',
    27 => 'powered_rail',
);



sub get_stats {
    my $player = shift;
    my %player_stats;

    my $ua = LWP::UserAgent->new;

    my $response = $ua->get(
        sprintf "http://the-wild.tk/stats/single_player.php?p=%s",
        $player
    );
    
    my $te = HTML::TableExtract->new(
        headers => [ qw(Block BlockID Placed Broken) ],
    );
    $te->parse($response->content);
    my ($table) = $te->tables
        or die "Failed to find blocks table in stats HTML";

    for my $row ($table->rows) {
        my ($block, $block_id, $placed, $broken) = @$row;
        warn "broke [$broken] '$block_id' blocks";

        if (my $block_name = $block_name_by_id{$block_id}) {
            warn "Interested in $block_name";
            $player_stats{broken}{$block_name} += $broken;
            $player_stats{placed}{$block_name} += $placed if $placed;
        }
    }

    for (qw(diamond gold)) {
        if ($player_stats{broken}{$_}) {
        $player_stats{ratio}{$_} = sprintf '%.4f', 
            $player_stats{broken}{$_} / $player_stats{broken}{stone};
        }
    }
    return \%player_stats;
}


