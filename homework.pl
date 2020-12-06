/* данный файл представляет собой выполнение 13 задач-лабораторных-дз по дисциплине Программирование, 
дополнительные главы. исполнитель -- Гончаров С.С., СГН3-11М. задачи разделены комментариями-заголовками. 
пролог-листинги предназначены для исполнения в web-ide swish*/

/* #1 -- вернуть последний элемент списка */

last_element([], _):- !, fail. % остановиться, если список пустой 
last_element([ Head | [] ], Head):- !. % вывести голову, если список из одного
last_element([ _ | Tail], Result) :- % сократить список на один с начала, если он не пуст
    last_element(Tail, Result).

/* #2 -- вернуть заданный по номеру элемент списка */

:- use_module(library(clpfd)).	% Finite domain constraints

element(_, [], _) :- !, fail. % если список пустой -- стоп
element(Result, [Result|_], 0) :- !. % если дошли до нужного по номеру -- останавливаемся и выводим
element(Result, [_|L], Pos) :- % при поиске нужного спускаемся вглубь списка, уменьшая счётчик до 0 (случай 2)
    New #= Pos - 1, %уменьшаем счётчик
    element(Result, L, New). %отнимаем 1 элемент, передаём укороченный массив

/* #3 -- проверить список на палиндромность */

reverting([], _, _) :- !, fail. % функция переворачивания; пустой список -- провал
reverting([H| []], Previous, [H | Previous]) :- !. % добавляем в список из 1 элемента, когда у нас в 1 списке осталась только голова, в обратном порядке
reverting([H|L], Previous, Result):- % добавляем в непустой список
    reverting(L, [H | Previous], Result). % уменьшаем первый список на голову, передаём во временный список обратным порядком

eq_check([], []) :- !, true. %проверка равенства списков; если оба пустые -- равны
eq_check([H1|L1], [H2|L2]) :- %поэлементно сравниваем два непустых списка, сокращая их на первые эл-ты
    H1 = H2,
    eq_check(L1, L2). %передаём проверку сокращённых списков рекурсивно

pal_check(List) :- % функция собственно проверки
    reverting(List, [], Reverted), % переворачиваем
    eq_check(List, Reverted). % проверяем равенство поэлементно

/* #4 -- сжать повторяющиеся элементы в 1 */

sim_packing([], ElemAcc, ListAcc, Res) :- %случай с уже пустым начальным списком
    append(ListAcc, [ElemAcc], Res), !. % объединяем в результирующий список результаты аккумуляции, если оставшийся начальный список пуст

    sim_packing([AccumElem|L], [AccumElem|Elems], ListAcc, Res) :- %случай, когда следующий эл-т нач. списка такой же, как и в прошлый раз
    append([AccumElem|Elems], [AccumElem], Accum), 
    pack_sim_elems(L, Accum, ListAcc, Res), !.

sim_packing([NewElem|L], ElemAcc, ListAcc,Res) :- % случай, когда сл. эл-т нач. списка другой
    append(ListAcc, [ElemAcc], List), 
    pack_sim_elems(L, [NewElem], List, Res).

pack([], Res) :- Res = [], !. % случай, когда массив пустой
pack([H | L], Res) :- % случай, когда не пустой
    sim_packing(L, [H], [], Res). % объединяем соседстоящие равные элементы в один

/* #5 -- указать число повторений эл-тов в массиве */

count_elem_seq([], Elem, CountAcc, ListAcc,Res) :-  % преобразуем счётчик и элемент в список, если массив остался пустой
    append(ListAcc, [ [Elem | [CountAcc]] ], Res), !. % записываем его в результат

count_elem_seq([H|L], H, CountAcc, ListAcc, Res) :- % если следующий элемент списка такой же, как предыдущий
    Acc is CountAcc + 1, % увеличиваем счётчик
    count_elem_seq(L, H, Acc, ListAcc, Res), !. % передаём дальше список без головы

count_elem_seq([H1|L], H2, CountAcc, ListAcc,Res) :- % если следующий элемент списка отличается от предыдущего
    append(ListAcc, [ [H2 | [CountAcc]] ], List), % записываем предыдущую последовательность в результат
    count_elem_seq(L, H1, 1, List, Res), !. % передаём дальше список без головы

encode([], Res) :- Res = [], !. % если список изначально пустой
encode([H | L], Res) :- % если список не пустой, приступаем к препарированию
    count_elem_seq(L, H, 1, [], Res).

/* #6 -- повторить число элементов, расшифровав его из списка на вход */
repeat_symbol(_, 0, Acc, Acc) :- !. %если число повторений 0 -- скип
repeat_symbol(Symbol, Count, Res, Acc) :- % повторяем 
    Next_count #= Count - 1, % уменьшаем число необходимых повторений
    append(Acc, [Symbol], Appended_list), % добавляем символ в список-результат
    repeat_symbol(Symbol, Next_count, Res, Appended_list). %продолжаем повторять

decode_by_sublist([], Acc, Acc) :- !. %если остался пустой список
decode_by_sublist([[Symbol|Count]|L], Acc, Res) :- %расшифровываем, беря сразу первый кортеж 
    repeat_symbol(Symbol, Count, Symbol_list, []), % формируем список-повтор элементов
    append(Acc, Symbol_list, Appended_list), %вставляем врезультат
    decode_by_sublist(L, Appended_list, Res). %продолжаем расшифровку

decode_modified([], Res) :- Res = [], !. %если список пустой
decode_modified(List, Res) :- %если не пустой
    decode_by_sublist(List, [], Res). %расшифровываем по подспискам

/* #7 -- дублировать каждый элемент списка */

double_symbol(Symbol, [Symbol | [Symbol] ]) :- !. % удваиваем символ

dupli_recursive([], Acc, Acc) :- !. % рекурсивно НЕ удваиваем, если дошли до конца, и массив результата равен массиву аккумуляции
dupli_recursive([H|L], Acc, Res) :- % рекурсивно удваиваем, 
    double_symbol(H, Symbols), % удваиваем символ
    append(Acc, Symbols, Appended_list), % добавляем удвоенный символ к аккумуляционному списку
    dupli_recursive(L, Appended_list, Res). % продолжаем препарацию входного списка

dupli(List, Res) :- 
    dupli_recursive(List, [], Res). % препарируем входной список с конца

/* #8 -- выбрасывать каждый I-й элемент списка */

drop_([], _, _, Acc, Acc) :- !. % если список пуст
drop_([H|L], I, Index_acc, Acc, Res) :- % если список не пуст
    Next_index #= Index_acc + 1, % увеличиваем индекс
    ( not(0 is mod(Next_index, I)) ->  % если индекс не тот
    	append(Acc, [H], Appended_list), % кладём отработанные элементы в новый список
        drop_(L, I, Next_index, Appended_list, Res) % передаём дальше уменьшенный начальный и отработанный списки
    ;   % если то, что надо
    	drop_(L, I, Next_index, Acc, Res) % передаём дальше списки без запоминания необходимого элемента
    ).

drop(List, I, Res) :-
    drop_(List, I, 0, [], Res).

/* #9 -- разбить список на два, величина первого известна */

split_([], _, _, Acc1, Acc2, Acc1, Acc2) :- !. % если список пустой...
split_([H|L], Len, Index, Acc1, Acc2, Res1, Res2) :- % если список не пустой
    Next_index #= Index + 1, 
    ( Next_index =< Len -> % если увеличенный индекс меньше/равен нужной длине
    	append(Acc1, [H], Appended_list), % добавляем текущую голову в список 1
        split_(L, Len, Next_index, Appended_list, Acc2, Res1, Res2) % продолжаем путь
    ;   
    	append(Acc2, [H], Appended_list), %если нет -- добавляем в список 2
        split_(L, Len, Next_index, Acc1, Appended_list, Res1, Res2) % продолжаем путь
    ).

split(List, Len, Res1, Res2) :- 
    split_(List, Len, 0, [], [], Res1, Res2).

/* по рекомендации Ромы Батина задания 10-12 реализованы вместе */

/* #10 -- левый сдвиг на Р эл-тов */
shift_left(List, Res) :- % левый сдвиг (Р больше 0)
    length(List, Len), % узнаём длину
    Index_end is Len - 1,
    remove_at(List, 0, Token, Processed_list),
    insert_at(Token, Processed_list, Index_end, Res).

shift_right(List, Res) :- % правый сдвиг (Р меньше 0)
    length(List, Len),
    Index_end is Len - 1,
    remove_at(List, Index_end, Token, Processed_list),
    insert_at(Token, Processed_list, 0, Res). 

rotate([], _, []) :- !.
rotate(List, 0, List) :- !.
rotate(List, Count, Res) :-
    (   Count > 0 ->  
   		shift_left(List, NewList),
        Count_change = -1
    ;   
    	shift_right(List, NewList),
        Count_change = 1
    ),
    New_count is Count + Count_change,
    rotate(NewList, New_count, Res).

/* #11 -- удаление N-го эл-та */

remove_at_([], _, _, Acc, _, Acc) :- !, fail. 
remove_at_([H|L], Pos, Pos, Acc, X, Res) :- X = H, append(Acc, L, Res), !.
remove_at_([H|L], Pos, Index, Acc, X, Res) :-
    Next_index is Index + 1,
    append(Acc, [H], Appended_list),
    remove_at_(L, Pos, Next_index, Appended_list, X, Res).

remove_at(List, Pos, X, Res) :-
    (   Pos #< 0 ->
    	length(List, Len),
        Index is Len + Pos
    ;
    	Index is Pos
    ),
    remove_at_(List, Index, 0, [], X, Res).

/* #12 -- вставить на указанную позицию */

insert_at_(Token, List, Pos, Pos, Acc, Res) :- append(Acc, [ Token | List ], Res), !.
insert_at_(Token, [H|L], Pos, Index, Acc, Res) :-
    Next_index is Index + 1,
    append(Acc, [H], Appended_list),
    insert_at_(Token, L, Pos, Next_index, Appended_list, Res).

insert_at(Token, List, Pos, Res) :-
    (   Pos #< 0 ->
    	length(List, Len),
        Index is Len + Pos + 1
    ;
    	Index is Pos
    ),
    insert_at_(Token, List, Index, 0, [], Res).

/* #13 -- создать список, содержащий все элемены в указанных границах */

range_fill(Start, End, _, _) :- End < Start, !, fail. % проверка на корректные границы
range_fill(End, End, Acc, Res) :- append(Acc, [ End ], Res), !. % если границы совпадают
range_fill(Start, End, Acc, Res) :- % если прошли все проверки
    Next is Start + 1, % создаём следующий эл-т
    append(Acc, [ Start ], Appended_list), % добавляем эл-ты в список
    range_fill(Next, End, Appended_list, Res). % продолжаем рекурсией

range(Start, End, Res) :-
	range_fill(Start, End, [], Res).