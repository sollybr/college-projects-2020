package Manager; #V 1.0.0
use lib "."; #USER, don't you DARE separate the program files. User. Don't. NO. D- DON'T.
use Client; #class of object we are using
#---------#
use strict;
use warnings;
#---------Fun begins---------#
sub insert { # first arg: file; second arg: object // Use ">>" on file
	my @list_of_args; my $counter=0;
	foreach (@_){
		$list_of_args[$counter] = $_;
		$counter += 1;
	}
	my $writethis = ""; my $isKey = 1;
	foreach (%{$list_of_args[1]}){
		$writethis = $writethis . $_;
		if ($isKey){
			$writethis = $writethis . "\t"; #Client attributes
			$isKey = 0;
		}
		else {
			$writethis = $writethis . "\n"; #Attributes Values
			$isKey = 1;
		}
	}
	print {$list_of_args[0]} $writethis . "---\n";
}

sub delete { #1st arg: list, 2nd arg: file, 3rd arg: object // open the file with ">".
	my @list_reference;
	for (my $counter = 0; $counter < $#_-1; $counter++) {
		push @list_reference, $_[$counter];
	}
	my $counter = search_obj(@list_reference, $_[$#_]);
	for (my $lets_remove_stuff = $counter; 
	$lets_remove_stuff < $#list_reference+1; 
	$lets_remove_stuff++) { 
		$list_reference[$lets_remove_stuff] = 
		$list_reference[$lets_remove_stuff+1];
	}
	pop @list_reference;
	my $we_writing_here = $_[$#_-1];
	for (my $counter = 0; $counter < $#list_reference+1; $counter++) {
		insert($we_writing_here, $list_reference[$counter]);
	}
	@list_reference;
}

sub update{ #1st args: list, 2nd arg: file, 3rd arg: object, 4th arg: object update. Open file with ">".
	my @this_is_list; my $actual_file = $_[$#_-2];
	for (my $counter = 0; $counter < $#_-2; $counter++) { #Getting the object
		push @this_is_list, $_[$counter];
	}
	my $counter = search_obj(@this_is_list, $_[$#_-1]); #Front-end nuisance eliminated
	$this_is_list[$counter-1] = $_[$#_];
	foreach (@this_is_list){
		insert($actual_file, $_); #Thank me later.
	}
	@this_is_list; #We done updating.
} 

sub list_all { #only takes a file arg. Use at the beginning of the main program. MUST. READ. FILE.
	my ($my_value, $my_key, %myObject, $key_and_value, @object_list);
	while (!eof ($_[0])){
		$key_and_value = readline $_[0];
		while ($key_and_value ne "---\n") {
			($my_key, $my_value) = split /\t/, $key_and_value;
			chomp ($my_key, $my_value);
			$myObject{$my_key} = $my_value;
			$key_and_value = readline $_[0];
		}
		push @object_list, %myObject;
	}
	@object_list;
}

sub search_obj{
	my $counter = 0; my $object_reference = $_[$#_];
	foreach (@_){
		last if $_->{name} eq $object_reference->{name};
		$counter++;
	}
	$counter;
}

1;
