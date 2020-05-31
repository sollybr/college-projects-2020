#pragma once

#ifndef LINKED_LIST_T
#define LINKED_LIST_T

struct l_list {
	void * object;
	struct l_list * next;
};

typedef struct l_list _ll;

// _ll * current_saved = NULL;

extern _ulli checkForItem(void *, 
							void *, 
							bool);

extern _ulli swap(_ll *, 
				_ll *, 
				_ulli, 
				_ulli);

void freeListObj(_ll * this_list, short delete_content){
	if (this_list == NULL) { return; }
	else {
		freeListObj(this_list->next, delete_content);
		if (this_list->object != NULL and 
			delete_content == 0) {

			free(this_list->object);
			this_list->object = NULL;
		} /* Recommended - avoid mem frag */
		this_list->next = NULL;
		free(this_list);
	}
}

_ll * createListNode (_ll ** pnt_to_prev, void * obj_addrs){
	*pnt_to_prev = (_ll*)malloc(sizeof(_ll));
	(*pnt_to_prev)->object = obj_addrs;
	(*pnt_to_prev)->next = NULL;
	return *pnt_to_prev;
}

#endif