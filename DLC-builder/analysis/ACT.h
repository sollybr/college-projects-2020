/* Abstract Circuit Tree

Abstract tree specified based on compiler building
approach to source code parsing.
Used to describe port reference, type and entries */

#pragma once

struct _tree_node;

typedef struct _tree_node {
	char * refer;
	_ulli node_count;
	struct _tree_node * f, * l, * r;
} node;

void lrootr(node * root){
	if (root != NULL) {
		lrootr(root->l);
		printf("%s\n", root->refer);
		lrootr(root->r);
	}
}

void nc_modify(node * this_n, bool incdec){
	if (this_n != NULL){
		if (incdec)
			this_n->node_count++;
		else
			this_n->node_count--;
		nc_modify(this_n->f, incdec);
	}
}

node * spawn_node( node * father,
					node ** this_node, 
					char * refer ){
	*this_node = (node*)malloc(sizeof(node));
	nc_modify(father, true);
	(*this_node)->node_count = 0;
	(*this_node)->f = father;
	(*this_node)->l = NULL;
	(*this_node)->r = NULL;
	(*this_node)->refer = (char*)malloc(strlen(refer));
	strcpy( (*this_node)->refer, refer );
	return *this_node;
}

void destroy_node(node * d_this){
	if (d_this != NULL){
		nc_modify(d_this->f, false);
		free(d_this->refer);
		destroy_node(d_this->l);
		destroy_node(d_this->r);
		free(d_this);
	}
}