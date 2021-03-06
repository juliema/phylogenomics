use CircleGraph;

=pod

CircleGraph $circlegraph_obj draw_circle_graph ( String $datafile, CircleGraph $circlegraph_obj )

$datafile is a tab-delimited file:
    -   the first column contains positions around a circle,
        scaled to the size of the last row's value
    -   each subsequent column contains the values to graph, one graph per column
    -   the first row contains the names of the columns
$circlegraph_obj is an optional parameter for an existing CircleGraph.

The function returns a CircleGraph object with the values plotted,
positions mapped around the edge, and a legend describing the graph.

=cut

sub draw_circle_graph {
    my $datafile = shift;
    my $circlegraph_obj = shift;
	my $circle_size = shift;
    unless ($circlegraph_obj) {
        $circlegraph_obj = new CircleGraph();
    }

    open DATAFH, "<$datafile" or die "$datafile failed to open\n";
    my $max_diffs = 0;
    my $total_elems;
    my @positions, @differences;

    my $line = readline DATAFH;
    $line =~ s/\n//;
    my @labels = split /\t/, $line;
    shift @labels;
    my @graphs = ();
    for (my $i=0; $i<@labels; $i++) {
        my @curr_array = ();
        push (@graphs, \@curr_array);
    }
    $line = readline DATAFH;

    while ($line ne "") {
        $line =~ s/\n//;
        my @items = split ('\t', $line);
        my $pos = shift @items;
        $total_elems = push (@positions, $pos);
        for (my $i=0; $i<@items; $i++) {
            @items[$i] =~ s/\n//;
            push (@{$graphs[$i]}, @items[$i]);
        }
        push (@differences, @items);
        $line = readline DATAFH;
    }

    my @sorted = sort {$a <=> $b} @differences;
    $max_diffs = @sorted[@sorted-1];
    $max_diffs =~ s/\n//;

    if ($max_diffs == 0) {
        die "Couldn't draw graph: all values are 0.";
    }

    for(my $i=0; $i<@graphs; $i++) {
        for (my $j=0; $j<@{$graphs[$i]}; $j++) {
            @{$graphs[$i]}[$j] = (@{$graphs[$i]}[$j]/$max_diffs);
        }
    }

    # draw background circles
    $circlegraph_obj->draw_circle($circlegraph_obj->inner_radius);
    $circlegraph_obj->draw_circle($circlegraph_obj->outer_radius);

    # draw graphs
    for (my $j=0; $j<@graphs; $j++) {
        $circlegraph_obj->plot_line(\@positions, $graphs[$j], {color=>$j});
        $circlegraph_obj->append_to_legend("@labels[$j]", "$j");
    }

    # draw labels around the edge
    $circlegraph_obj->set_font("Helvetica", 6, "black");
    if ($circle_size eq "") {
		$circle_size = @positions[@positions-1];
	}

    for (my $i = 0; $i < $total_elems; $i++) {
        my $angle = (@positions[$i]/$circle_size) * 360;
        my $radius = $circlegraph_obj->outer_radius + 10;
        my $label = @positions[$i];
        if (($label % 1000)!=0) { $label = "-"; }
        $circlegraph_obj->circle_label($angle, $radius, "$label");
    }

    $circlegraph_obj->draw_circle($circlegraph_obj->inner_radius, {'filled'=>1, 'color'=>"white"} );
    $circlegraph_obj->draw_circle($circlegraph_obj->inner_radius);

    $circlegraph_obj->append_to_legend("Maximum percent difference ($max_diffs) is scaled to 1");
    return $circlegraph_obj;
}

=pod

CircleGraph $circlegraph_obj plots_around_circle ( String $datafile, CircleGraph $circlegraph_obj )

$datafile is a tab-delimited file:
    -   the first column contains positions around a circle
    -   each subsequent column contains the values to graph, one graph per column
    -   the first row contains the names of the columns
$circlegraph_obj is an optional parameter for an existing CircleGraph.

The function returns a CircleGraph object with the values plotted,
positions mapped around the edge, and a legend describing the graph.

=cut

sub plots_around_circle {
    my $datafile = shift;
    my $circlegraph_obj = shift;
	my $circle_size = shift;
    unless ($circlegraph_obj) {
        $circlegraph_obj = new CircleGraph();
    }

    open DATAFH, "<$datafile" or die "$datafile failed to open\n";
    my $max_diffs = 0;
    my $total_elems;
    my @positions, @differences;

    my $line = readline DATAFH;
    $line =~ s/\n//;
    my @labels = split /\t/, $line;
    shift @labels;
    my @graphs = ();
    for (my $i=0; $i<@labels; $i++) {
        my @curr_array = ();
        push (@graphs, \@curr_array);
    }
    $line = readline DATAFH;

    while ($line ne "") {
        $line =~ s/\n//;
        my @items = split ('\t', $line);
        my $pos = shift @items;
        $total_elems = push (@positions, $pos);
        for (my $i=0; $i<@items; $i++) {
            @items[$i] =~ s/\n//;
            push (@{$graphs[$i]}, @items[$i]);
        }
        push (@differences, @items);
        $line = readline DATAFH;
    }

    my @sorted = sort {$a <=> $b} @differences;
    $max_diffs = @sorted[@sorted-1];
    $max_diffs =~ s/\n//;

    if ($max_diffs == 0) {
        die "Couldn't draw graph: all values are 0.";
    }

    for(my $i=0; $i<@graphs; $i++) {
        for (my $j=0; $j<@{$graphs[$i]}; $j++) {
            @{$graphs[$i]}[$j] = (@{$graphs[$i]}[$j]/$max_diffs);
        }
    }

    # draw background circles
    $circlegraph_obj->draw_circle($circlegraph_obj->inner_radius);
    $circlegraph_obj->draw_circle($circlegraph_obj->outer_radius);

    # draw graphs
    for (my $j=0; $j<@graphs; $j++) {
        $circlegraph_obj->plot_points(\@positions, $graphs[$j], {color=>$j,radius=>((($j+1)*15)-5),width=>10,angle=>0.3});
        $circlegraph_obj->append_to_legend("@labels[$j]", "$j");
    }

    $circlegraph_obj->draw_circle($circlegraph_obj->inner_radius, {'filled'=>1, 'color'=>"white"} );
    $circlegraph_obj->draw_circle($circlegraph_obj->inner_radius);

    return $circlegraph_obj;
}


=pod

CircleGraph $circlegraph_obj draw_gene_map ( String $gene_file, CircleGraph $circlegraph_obj )

$gene_file is a tab-delimited file of gene locations, such as generated by get_locations_from_genbank_file()
$circlegraph_obj is an optional parameter for an existing CircleGraph.

The function returns a CircleGraph object with the gene locations plotted around the edge
of an inner circle and the names plotted inside the circle.

=cut

sub draw_gene_map {
    my $gene_file = shift;
    my $circlegraph_obj = shift;
    my $params = shift;

    unless ($circlegraph_obj) {
        $circlegraph_obj = new CircleGraph();
    }

    my $direction = "IN";
	my $width = 5;
	my $color = "tardis";
    if (ref($params) eq "HASH") {
        if (exists $params->{"direction"}) {
            $direction = $params->{"direction"};
        }
        if (exists $params->{"width"}) {
            $width = $params->{"width"};
        }
        if (exists $params->{"color"}) {
            $width = $params->{"color"};
        }
    }


    open INPUTFILE, "<$gene_file" or die "$gene_file failed to open\n";
    my @inputs = <INPUTFILE>;
    close INPUTFILE;

    while (@inputs[0] !~ /\t/) { #there's some sort of header
        shift @inputs;
        if (@inputs == 0) {
            die "no data in $gene_file.\n";
        }
    }

    (undef, undef, my $circle_size, undef) = split /\t/, pop @inputs;
    $circle_size =~ s/\n//;

    my @labels = ();
    for (my $i = 0; $i < @inputs; $i++) {
        my $line = @inputs[$i];
        my ($label, $start, $stop, $value) = split /\t/, $line;
        $value =~ s/\n//;
        if ($value eq "") {
            $value = 0;
        }

        my $start_angle = ($start/$circle_size) * 360;
        my $stop_angle = ($stop/$circle_size) * 360;
        my $radius = $circlegraph_obj->inner_radius;
        if ($direction eq "OUT") {
        	$radius = $circlegraph_obj->outer_radius + $width;
        }

        $circlegraph_obj->draw_filled_arc ($radius, $start_angle, $stop_angle, {color=>$color});

        # label this element
        my $center_angle = ($start_angle + $stop_angle) / 2;
        push @labels, "$label\t$center_angle";
    }
	if ($direction eq "OUT") {
		$circlegraph_obj->draw_circle($circlegraph_obj->outer_radius, {filled => 1, color => "white"});
		$circlegraph_obj->draw_circle($circlegraph_obj->outer_radius);
		$circlegraph_obj->set_font("Helvetica", 8, "black");
		foreach my $line (@labels) {
			$line =~ /(.+?)\t(.+?)$/;
			$circlegraph_obj->circle_label($2, $circlegraph_obj->outer_radius + 5 + $width, $1, "left");
		}
	} else {
		$circlegraph_obj->draw_circle($circlegraph_obj->inner_radius - $width, {filled => 1, color => "white"});
		$circlegraph_obj->draw_circle($circlegraph_obj->inner_radius);
		$circlegraph_obj->set_font("Helvetica", 6, "black");
		foreach my $line (@labels) {
			$line =~ /(.+?)\t(.+?)$/;
			$circlegraph_obj->circle_label($2, $circlegraph_obj->inner_radius - 5 - $width, $1, "right");
		}
	}
    return $circlegraph_obj;
}

=pod

CircleGraph $circlegraph_obj draw_regions ( String $region_file, CircleGraph $circlegraph_obj, (optional) $color, (optional) $radius )

$region_file is a tab-delimited file of region locations, with the size of the circle as the last entry.
$circlegraph_obj is an optional parameter for an existing CircleGraph.

=cut

sub draw_regions {
    my $region_file = shift;
    my $circlegraph_obj = shift;
    my $color = shift;
    my $radius = shift;
    unless ($circlegraph_obj) {
        $circlegraph_obj = new CircleGraph();
    }

    if ($color eq "") {
        $color = "tardis";
    }
    unless ($radius) {
        $radius = $circlegraph_obj->inner_radius;
    }

    open INPUTFILE, "<$region_file" or die "$region_file failed to open\n";
    my @inputs = <INPUTFILE>;
    close INPUTFILE;

    while (@inputs[0] !~ /\t/) { #there's some sort of header
        shift @inputs;
        if (@inputs == 0) {
            die "no data in $region_file.\n";
        }
    }
    (undef, undef, my $circle_size, undef) = split /\t/, pop @inputs;
    $circle_size =~ s/\n//;

    my @labels = ();
    for (my $i = 0; $i < @inputs; $i++) {
        my $line = @inputs[$i];
        my ($label, $start, $stop, $value) = split /\t/, $line;
        $value =~ s/\n//;
        if ($value eq "") {
            $value = 0;
        }

        my $start_angle = ($start/$circle_size) * 360;
        my $stop_angle = ($stop/$circle_size) * 360;

        $circlegraph_obj->draw_arc ($radius, $start_angle, $stop_angle, {color => "$color", width => 3});
    }

    return $circlegraph_obj;
}


# must return 1 for the file overall.
1;
