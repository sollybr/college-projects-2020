#define 	STD_FILE_NAME "descrp.txt"

#define 	_ulli unsigned long long

#ifdef		MAX_ENTRIES
#undef 		MAX_ENTRIES
#endif

#define 	CHARZERO 48
#define 	MAX_ENTRIES 10
#define 	MAX_CHAR_PER_LINE \
			(2+MAX_ENTRIES) * MAX_TOKEN_LENGTH

#include 	<stdio.h>
#include 	<string.h>
#include 	<stdlib.h>
#include 	<iso646.h>
#include 	<stdbool.h>

#include 	"utils/specs.h"
#include	"utils/trim.h"

#include 	"struct/structures.h"
#include 	"analysis/analysis.h"

typedef struct {
	void * my_addr;
	char * refer;
} mpr;

char * all_port_refers;

extern	bool 	calcByType	( short, bool, bool );
extern  short	getPortType	( node * );
short	circuitInit			( _ulli *, _ulli * );
void	incrementCase		( bool * , _ulli );
c_port 	*getPortAddress 	( char * , mpr *, _ulli );
_ll 	*fromFileGetLines	( FILE **, _ulli * );

int main (int argc, char ** argv){
	
	FILE * f_point;
	char * input_filename = malloc(strlen(STD_FILE_NAME));
	strcpy(input_filename, STD_FILE_NAME);
	if (argc > 1){
		input_filename = 
			realloc(input_filename, strlen(argv[1]));
		strcpy(input_filename, argv[1]);
	}	
	f_point = fopen(input_filename, "rb");
	if (f_point == NULL) {
		printf("File not found.\n");
		return -1;
	}

	_ulli _error = 0;
	_ll * list_tokencurrent_lines = 
		fromFileGetLines( &f_point, &_error );
	fclose(f_point);
	if (_error == 0){
		printf("File isn't in a valid format.\n" );
		return -2;
	}

	/* Scan begins */
	_error = getTokens(list_tokencurrent_lines, _error);
	if (_error != 0) {
		printf("Scan error: Invalid token size.\n");
		_ulli i = 1; _ll * errorcurrent_line;
		for (errorcurrent_line = list_tokencurrent_lines; 
			i < _error; ++i) {
			errorcurrent_line = errorcurrent_line->next;
		}
		printf("Line %llu: %s\n", _error, 
			(char*)errorcurrent_line->object);
		return -3;
	}
	/* Scan ends */

	freeListObj(list_tokencurrent_lines, 0);
	list_tokencurrent_lines = NULL;

	/* parsing starts here */
	parseParams(scanned_tokens);
	/* parsing ends here */

	/* Tree analysis starts here */
	_ulli num_outputs = 0;
	_error = 
		(_ulli)circuitInit( &num_inputs, 
							&num_outputs );
	/* Tree analysis ends here */

	if (_error != 0){
		if (_error == -1){
			printf("Port owns itself as input.\n");
			return -4;
		}
		if (_error == -2){
			printf("Too many undeclared outputs.\n");
			return -5;
		}
        else {
            printf("Unknown error.\n");
            return -7;
        }
	}

	char * output_filename = 
		malloc(9*sizeof(char) + strlen(input_filename)),
	* tmp = strtok(input_filename, ".");
	strcpy(output_filename, tmp);
	strcat(output_filename, "_out.txt"); 
	tmp = NULL;
	f_point = fopen(output_filename, "wb");
	if (f_point == NULL){
		printf("Writing permissions denied.\n");
		return -6;
	}

	fputs(all_port_refers, f_point); 
	fputc('\n', f_point);

	for (_ulli i = 0; i < pow(2, num_inputs); ++i) {

		for (_ulli j = 0; j < num_inputs; ++j)
		{
			char this_value[] = 			
			{ (char)(CHARZERO+inp_values[j]), '\t', '\t', '\0' };
			fputs( this_value, f_point);
		} 

		for (_ulli j = 0; j < num_outputs; ++j) {

			bool new_result = calculateOutput(out_addresses[j]);
			char result[] = 
				{(char)(new_result+CHARZERO), '\t', '\t', '\0'};
			fputs( result, f_point);

		}
		fputc('\n', f_point);
		incrementCase(inp_values, num_inputs);
	}
	return 0;
}

_ll * fromFileGetLines(FILE ** file_pointer, _ulli * lnc){

	char * current_line = 
		malloc(MAX_CHAR_PER_LINE*sizeof(char));
	_ll * first_in_hold = NULL, * hold_this = NULL;
	while ( fgets( current_line, 
					MAX_CHAR_PER_LINE, 
					*file_pointer) != NULL ) {
		strcpy(current_line, 
			trimString(current_line, " \r\n\t"));
		char * save_current_line = NULL, * _tmp_ = NULL;

		if (current_line[0] != '#'){

			if (strlen(current_line) > MIN_TOKEN_LENGTH) {

				_tmp_ = strtok( current_line, COMM_SYMBOL );
				if (_tmp_ == NULL){
					save_current_line = 
						(char*)malloc(strlen(current_line));
					strcpy(save_current_line, current_line);
				}
				else {
					save_current_line = 
						(char*)malloc(strlen(_tmp_));
					strcpy(save_current_line, _tmp_);
				}

				if (save_current_line != NULL and 
						strlen(save_current_line) >= MIN_TOKEN_LENGTH) {

					if ( first_in_hold == NULL ){ 
						first_in_hold = 
							createListNode( &hold_this, 
											save_current_line );
					}
					else {
						hold_this = 
							createListNode( &(hold_this->next), 
											save_current_line );
					}
					++(*lnc);
				}
			}
			else if (strlen(current_line)>0){
				*lnc = 0;
				return NULL;
			}
		}
		/* If line is tiny, or 
			comment-only, ignore. Else ... */
	} return first_in_hold;
}

_ulli checkForItem( void * head, 
					void * object,
					bool _type ){

	_ulli i = 0;
	if (_type == 0){
		for (_ll * p = (_ll*)head; 
			p != NULL;
			p = p->next) { 
			node * test = (node*)p->object;
			if( strcmp( test->refer, 
				(char*)object ) == 0) {
				break;
			}
			i++; 
		}
	}
	else {
		node * p = (node*)head;
		while ( p != NULL ) { 
		
			if( strcmp( p->refer, 
				(char*)object ) == 0){
				break;	
			}
			i++;
			p = p->r;
		}
	}
	return i;
} /* Return item position (< objects qnt.) if found */

c_port * getPortAddress ( 	char * my_refer, 
							mpr * catalogue,
							_ulli num_checked ) {

	for (_ulli i = 0; i < num_checked; i++) {
		
		if (strcmp( (catalogue[i].refer), my_refer ) == 0){
			return (c_port*)(catalogue[i].my_addr);
		}
	} return NULL;
}

void incrementCase( bool * my_inp_values, _ulli inps_quant ){
	bool extra_add = false;
	for (_ulli i = 0; i < inps_quant; ++i)
	{
		if (my_inp_values[i] == 1){
			extra_add = true;
			my_inp_values[i] = 0;
		}
		else {
			my_inp_values[i] = 1;
			break;
		}
	}
} /* Increment each entry "bit" by 1 til all of them are 1 */

short circuitInit(_ulli *found_inputs, _ulli *found_outputs) {

  _ulli num_checked = 0;
  _ll *all_refers = NULL, *this_refer = NULL;

  for (_ll *p = all_parseds; p != NULL; p = p->next) {

    node *root = (node *)(p->object);
    node *current_node = root;

    while (current_node != NULL) {

      if (root != current_node and
          strcmp(root->refer, current_node->refer) == 0) {
        return -1;
      } /* If port has itself as entry, then ERROR */

      else {

        _ulli check_this = checkForItem(all_refers, current_node->refer, 0);

        if (check_this == num_checked) {

          if (all_refers == NULL) {
            all_refers = createListNode(&this_refer, current_node);
          } else {
            this_refer = createListNode(&(this_refer->next), current_node);
          }
          ++num_checked;
        } /* 	If it wasn't seen before ... */
        else {

          node *found_node = NULL;
          _ll *actual_refer = NULL;

          for (actual_refer = all_parseds; actual_refer != NULL;
               actual_refer = actual_refer->next) {

            found_node = (node *)(actual_refer->object);

            if (strcmp(found_node->refer, current_node->refer) == 0) {
              break;
            }
            /* 	Check if was declared
            in circuit description */
          }

          node *__fn = NULL;
          _ll *previous_refer;

          for (previous_refer = all_refers; previous_refer != NULL;
               previous_refer = previous_refer->next) {

            __fn = (node *)previous_refer->object;
            if (strcmp(__fn->refer, current_node->refer) == 0) {
              break;
            }
          }
          if (actual_refer == NULL) {
            __fn->node_count = 0;
          } /* Wasn't explicitly declared
            -> must be input */
          else {
            previous_refer->object = found_node;
          }
          /* 	Replace port entry-like
                  refer with actual refer */
        } /* 	If it WAS seen before ... */
      }   /* 	No error. Yay. */
      if (root->r == NULL) {
        current_node = current_node->l;
      } else {
        current_node = current_node->r;
      }
    } /* 	Check all entries refers for this port */
  }   /* 	Create references to all ports, inputs and outputs */

  char custom_out_A = (char)CHARZERO, custom_out_B = (char)CHARZERO;
  const char cus_out_str[] = "MYO";
  _ulli i = 0, j = 0, k = 0;
  for (_ll *q = all_refers; q != NULL && i < num_checked; q = q->next) {

    i++;
    bool was_called = false;
    node *this_test = (node *)(q->object);

    if (this_test->l == NULL or this_test->r != NULL) {

      if (this_test->l == NULL) {
        (*found_inputs)++;
        this_test->node_count = 0;
      }

      j = 0;

      for (_ll *_q = all_refers; _q != NULL && j < num_checked; _q = _q->next) {

        j++;
        node *test = (node *)(_q->object);

        if (this_test != test and test->l != NULL) {

          if (test->r != NULL) {

            _ulli never_called = checkForItem(test, this_test->refer, 1);

            if (never_called < test->node_count) {
              was_called = true;
              break;
            }
          } /*  Port can't call itself */
          else {
            if (strcmp((test->l)->refer, this_test->refer) == 0) {
              was_called = true;
              break;
            }
          }
        }
      }

      if (!was_called) {
        char *new_refer = malloc(6 * sizeof(char));
        strcpy(new_refer, cus_out_str);
        int new_char = strlen(new_refer);
        new_refer[new_char] = custom_out_A;
        new_refer[new_char + 1] = custom_out_B;
        new_refer[new_char + 2] = '\0';
        if ((int)custom_out_B == CHARZERO + 9) {

          if ((int)custom_out_A == CHARZERO + 9) {
            return -2;
            /* Too many undeclared outputs */
          } else {
            custom_out_B = (char)(CHARZERO);
            custom_out_A = (char)(1 + (int)(custom_out_A));
          }
        } else {
          custom_out_B = (char)(1 + (int)(custom_out_B));
        }
        node *my_node = NULL;
        spawn_node(NULL, &my_node, new_refer);
        spawn_node(my_node, &(my_node->l), this_test->refer);
        this_refer = createListNode(&(this_refer->next), my_node);
        k++;
        (*found_outputs)++;
      }
    } /* 	If a output, then ignore. */
    /* 	Will create "output ports" to receive
            never-called ports' results */
    else {
      ++(*found_outputs);
    }
  }
  num_checked += k;

  all_port_refers = malloc(MAX_TOKEN_LENGTH * sizeof(char) * num_checked);
  strcpy(all_port_refers, "");

  inp_values = malloc(*found_inputs * sizeof(bool));
  inp_addresses = malloc(*found_inputs * sizeof(c_port *));
  // out_values = malloc(*found_outputs * sizeof(bool));
  out_addresses = malloc(*found_outputs * sizeof(c_port *));

  ports_address = (c_port *)malloc(num_checked * sizeof(c_port));
  mpr *refer_list = (mpr *)malloc(num_checked * sizeof(mpr));

  _ll *this_root_refer = all_refers;

  for (_ulli i = 0; i < num_checked; ++i) {

    node *_this_node = (node *)(this_root_refer->object);
    (refer_list[i]).my_addr = (c_port *)(ports_address + i);
    (refer_list[i]).refer = _this_node->refer;
    if (_this_node->l == NULL or _this_node->r == NULL) {
      strcat(all_port_refers, _this_node->refer);
      strcat(all_port_refers, "\t\t");
    }
    this_root_refer = this_root_refer->next;
  } /* Create refers to ports addresses
          through refer_string */
  this_root_refer = NULL;

  _ll *save_this = all_refers;
  _ulli track_inps = 0, track_outs = 0;

  for (_ulli i = 0; i < num_checked; ++i) {

    node *this_node = (node *)(save_this->object);
    _ulli num_entries = 0;
    if (this_node->l != NULL) {

      num_entries = (this_node->r == NULL) ? 1 : (this_node->node_count) - 1;
      /* Outputs only have 1 entry */
    } /* If it's input, 0 num_entries ELSE ... */

    c_port **my_entries = NULL;
    if (num_entries != 0) {

      my_entries = (c_port **)malloc(num_entries * sizeof(c_port *));
      node *this_entry = NULL;

      this_entry = (this_node->r == NULL) ? this_node->l : this_node->r;

      for (_ulli i = 0; i < num_entries; ++i) {

        my_entries[i] =
            getPortAddress(this_entry->refer, refer_list, num_checked);
        this_entry = this_entry->r;
      }
    }

    c_port *this_addr =
        portSpawn(getPortAddress(this_node->refer, refer_list, num_checked),
                  getPortType(this_node), my_entries, num_entries);

    if (this_node->r == NULL or this_node->l == NULL) {
      if (this_node->l == NULL) {

        inp_values[track_inps] = false;
        inp_addresses[track_inps++] = this_addr;
      } else {
        out_addresses[track_outs++] = this_addr;
      }
    }
    // else {
    // }
    save_this = save_this->next;
  }
  return 0;
}