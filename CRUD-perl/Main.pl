use lib ".";
use v5.6.1; 
use Client;
use Manager;
#Variáveis_Globais
my @uma_lista;
my @lista_de_clientes;
my $fh_nm = "registro.data";
my $fh;
my $error_ = "";
#Fim_Variáveis
use strict;
use warnings;
#Care.
open $fh, ">>", $fh_nm;
close $fh;
open $fh, "<", $fh_nm;
@uma_lista = Manager::list_all($fh);
for (my $counter = 0; $counter < $#uma_lista+1; $counter+=4) {
	my $name; my $address; my $cl_rd;
	if ($uma_lista[$counter] eq "name"){
		$name = $uma_lista[$counter+1];
		$address = $uma_lista[$counter+3];
	}
	else {
		$name = $uma_lista[$counter+3];
		$address = $uma_lista[$counter+1];
	}
	$cl_rd = Client->new(name=>"$name", address=>"$address");
	push @lista_de_clientes, $cl_rd; 
}
close $fh;

while(1){
	system("cls");
	my $first_="$error_\n1. Incluir	2. Remover.\n";
	my $second_= "3. Atualizar	4. Listar.\n\nOpcao:";
	print("$first_$second_");
	$error_ = "";
	my $in_put = <STDIN>;
	if ($in_put == 1){
		my ($cl, $nome, $endereco);
		print("Escreva nome do usuario.:");
		$nome = <STDIN>;
		chomp $nome;
		print("\nEscreva endereco do usuario.:");
		$endereco = <STDIN>;
		if (!($endereco eq "\n" or $nome eq "\n")){
			chomp $endereco;
			open $fh, ">>", $fh_nm;
			$cl = Client->new(name=>$nome, address=>$endereco);
			Manager::insert($fh, $cl);
			close $fh;
			open $fh, "<", $fh_nm;
			@uma_lista = Manager::list_all($fh); $#lista_de_clientes=-1;
			for (my $counter = 0; $counter < $#uma_lista+1; $counter+=4) {
				my $name; my $address; my $cl_rd;
				if ($uma_lista[$counter] eq "name"){
					$name = $uma_lista[$counter+1];
					$address = $uma_lista[$counter+3];
				}
				else {
					$name = $uma_lista[$counter+3];
					$address = $uma_lista[$counter+1];
				}
				$cl_rd = Client->new(name=>"$name", address=>"$address");
				push @lista_de_clientes, $cl_rd; 
			}
			close $fh;
		}
	}

	elsif($in_put == 2){
		if ($#lista_de_clientes >= 0){
			my $counter;
			foreach(@lista_de_clientes){
				$counter++;
				print "$counter.$_->{name}\n";
			}
			print("Qual deletar?\nNumero:");
			my $in_put = <STDIN>;
			if (($in_put eq "\n") == 0){
				open $fh, ">", $fh_nm;
				@lista_de_clientes = Manager::delete(@lista_de_clientes, $fh, $lista_de_clientes[$in_put-1]);
				close $fh;
			}
			open $fh, "<", $fh_nm;
			@uma_lista = Manager::list_all($fh); $#lista_de_clientes=-1;
			for (my $counter = 0; $counter < $#uma_lista+1; $counter+=4) {
				my $name; my $address; my $cl_rd;
				if ($uma_lista[$counter] eq "name"){
					$name = $uma_lista[$counter+1];
					$address = $uma_lista[$counter+3];
				}
				else {
					$name = $uma_lista[$counter+3];
					$address = $uma_lista[$counter+1];
				}
				$cl_rd = Client->new(name=>"$name", address=>"$address");
				push @lista_de_clientes, $cl_rd; 
			}
			close $fh;
		}
		else {
			$error_ = "Sem clientes\n";
		}
	}
	elsif($in_put == 3){
		if ($#lista_de_clientes >= 0){
			my $counter;
			foreach(@lista_de_clientes){
				$counter++;
				print "$counter.$_->{name}\n";
			}
			print("Qual atualizar? Aperte \"ENTER\" para cancelar.\nNumero: ");
			my $choice = <STDIN>;
			if (($choice eq "\n") == 0){
				my $comfy = 0;
				print("Atualizar nome. Aperte \"ENTER\" para atualizar apenas endereco\nNome atual: ");
				my $new_nome = <STDIN>;
				print("Atualizar endereco. Aperte \"ENTER\" para atualizar apenas nome\nNovo endereco: ");
				my $new_add = <STDIN>;
				if ($new_nome eq "\n"){
					$new_nome = $lista_de_clientes[$choice-1]->{name};
					$comfy++;
				}
				if ($new_add eq "\n"){
					$new_add = $lista_de_clientes[$choice-1]->{address};
					$comfy++;
				}
				if ($comfy < 2){
					chomp $new_nome; chomp $new_add;
					my $updated = Client->new(name=>$new_nome, address=>$new_add);
					open $fh, ">", $fh_nm;
					@lista_de_clientes = Manager::update(@lista_de_clientes, $fh, $lista_de_clientes[$choice], $updated);
					close $fh;
				}
			}
		}
		else {
			$error_ = "Sem clientes\n";
		}
	}
	elsif($in_put == 4){
		if ($#lista_de_clientes >= 0){
			print "\n";
			foreach(@lista_de_clientes){
				print "$_->{name}\t$_->{address}\n";
			}
			my $go_next = <STDIN>;
		}
		else{
			$error_ = "Sem clientes\n";
		}
	}
	else{
		$error_ = "Opcao invalida. Tente novamente.\n";
	}
}