#!/bin/bash

## FR ######
# txt_onlyTaskToBeIncoiced="Seulement les travaux non facturés"
# txt_allTasks="Tous les travaux (même ceux qui ont déjà été facturés)"
# txt_Projects="Projets"
# txt_Tasks="Travaux"
# txt_ThisYear="Cette année"
# txt_ThisMonth="Ce mois-ci"
# txt_LastMonth="Le mois dernier"
# txt_LastQuarter="Le dernier trismestre"
# txt_ThisQuarter="Ce trismestre"
# txt_Total="Total"
# tag_invoiced="fact_ok"
# tag_toBeInvoiced="a_fact"
############

## EN ######
txt_onlyTaskToBeIncoiced="Only tasks to be invoiced"
txt_allTasks="All tasks (even if already invoiced)"
txt_Projects="Projects"
txt_Tasks="Trasks"
txt_ThisYear="This year"
txt_ThisMonth="This month"
txt_LastMonth="Last month"
txt_LastQuarter="Last quarter"
txt_ThisQuarter="This quarter"
txt_Total="Total"
tag_invoiced="invoiced"
tag_toBeInvoiced="to_inv"
############

defaultPeriod=":month"


blue=$(tput setaf 4)
normal=$(tput sgr0)

searchGroupTag(){
	local input

	list=()
	for n in $(timew tags  | sed ':a;N;$!ba;s/-\n/\n/g')
	
		do
		  IFS="," read -a params <<< $n
		  for (( i=0; i<=${#params[@]}; i++ )); do
		  
			  if [[ ${params[$i]} == *"$1:"* ]]; then
			  
				  if [[ " ${list[*]} " != *${params[$i]}* ]]; then
				 
				 	 list+=(${params[$i]})
				  fi
			  fi
			    
		done
	 
	done
	printf "\n\n-----\n">&2
	for (( i=0; i<=${#list[@]}; i++ )); do

		echo "${blue}["$((i+1))"]${normal} : "${list[$i]//$1:/}>&2
	done


	printf "\n\n-----\n">&2
	if [[ ${#list[@]} < 10 ]]; then
		read -p "${blue}Your choice${normal} (ex:1) : " groupId
	else
		read -rsn1 groupId
	fi
	
	
	echo ${list[$((groupId-1))]}
		
}

#markAsInvoiced() {

#	if ! [ -z "$1" ]
#		then
#			return
#		fi
	
#	timew tag $(timew summary $1 :ids '$tag_toBeInvoiced' | awk -F "@" '{if($2!="") print "@"$2}' | awk -F " " '{print $1}' |  tr "\n" " ") '$tag_invoiced'
#	timew untag $(timew summary $1 :ids '$tag_toBeInvoiced' | awk -F "@" '{if($2!="") print "@"$2}' | awk -F " " '{print $1}' |  tr "\n" " ") '$tag_toBeInvoiced'

#}

report() {

	if ! [ -z "$1" ]
	then
		period=$1
	else
		period=$(date --date="15 day ago" +%Y-%m-%d)" - today"
	fi
	
	if ! [ -z "$2" ]
	then
		p2=$2
	else
		p2=""
	fi
	
	if ! [ -z "$3" ]
	then
		p3=$3
	else
		p3=""
	fi

	timew summary $period $p2 $p3 :ids
}

mainMenu() {
	local action
	

	if ! [ -z "$1" ]
	then
		action=$1
	else
		printf "\n\n-----\n">&2
		printf "${blue}[C]${normal}ontinue ${blue}[S]${normal}earch  -  add ta${blue}[G]${normal} to active  -  ${blue}[N]${normal}ew ${blue}[E]${normal}dit   s${blue}[T]${normal}op ${blue}[R]${normal}emove  -  ${blue}[D]${normal}ay ${blue}[W]${normal}eek ${blue}[M]${normal}onth ${blue}[Y]${normal}ear  -  re${blue}[P]${normal}lace tag  -  ${blue}[I]${normal}nvoice\n">&2
		read -rsn1 -t1 action
	fi
	if [ -z "$action" ]
	then
		
		report $defaultPeriod
		mainMenu
		return
	fi
	if [ $action == "s" -o $action == "S" ]
	then
		
		client=$(searchGroupTag cli)
		read -p "${blue}Search${normal} $client : " search
		
		for n in $(timew summary 2000-01-01 - 2050-01-01 $client :ids   | awk -F "@" '{if($2!="") print "@"$2}' | sed "s/[0-9]*[0-9]*:[0-9][0-9]*:[0-9][0-9]*/  /g" | sed "s/ /_____/g" | sed 's/\t/_____/g')
		do
		  IFS="," read -a params <<< $n
		  isMatch=false
  		  taskId=${params[0]}
		  cli=""
		  proj=""
		  task=""
		  invoiced="" 
		  for (( i=0; i<=${#params[@]}; i++ )); do
			  
			  if [[ ${params[$i]} == *"cli:"* ]]; then
				  cli=${params[$i]} 
			  else
				if [[ ${params[$i]} == *"proj:"* ]]; then
					  proj=${params[$i]} 
				 else
				   
					if [[ ${params[$i]} == *$tag_invoiced* ]]; then
						  invoiced=${params[$i]} 
					 else
					 	if [[ ${params[$i]} == *$tag_toBeInvoiced* ]]; then
							  invoiced=${params[$i]} 
						 else
						 	if [[ ${params[$i]} == *$search* ]]; then
								  isMatch=true
								  task=${params[$i]} 
							  fi
							 
						 fi
					 fi
				  
				  fi
			  
			  fi
			  
		  done
		  
	
		  
		  taskId=`echo ${taskId//"_____"/" "} | sed 's/ *$//g'`
		  task=`echo ${task//"_____"/" "} | sed 's/ *$//g'`
		  proj=`echo ${proj//"_____"/" "} | sed 's/ *$//g'`
		  cli=`echo ${cli//"_____"/" "} | sed 's/ *$//g'`
		  
		  if ( $isMatch == true ); then
		  	printf "\n${taskId//"_____"/" "} : ${task//"_____"/" "} (${proj//"_____"/" "})">&2
		  fi
		 
		done
		
		while [ false ]
		do
			printf "\n\n-----\n">&2
			printf "${blue}[B]${normal}ack ${blue}[S]${normal}search ${blue}[C]${normal}ontinue ">&2
			read -rsn1 continue
			if [ $continue == "b" -o $continue == "B" ]
			then
				mainMenu
				return
			fi
			if [ $continue == "s" -o $continue == "S" ]
			then
				mainMenu s
				return
			fi
			if [ $continue == "c" -o $continue == "C" ]
			then
				read -p "${blue}Task Id${normal} (ex:1) : " WhatToContinue
				timew continue @$WhatToContinue
				timew untag $tag_invoiced
				timew tag $tag_toBeInvoiced
				
				report $defaultPeriod
				mainMenu
				return
			fi
			
		done
		

	fi
	
	
	
	
	
	if [ $action == "n" -o $action == "N" ]
	then
		timew stop
		timew start
		client=$(searchGroupTag cli)
		project=$(searchGroupTag proj)
		read -p "${blue}Task name${normal} : " task
		task=`sed -e 's/^"//' -e 's/"$//' <<<"$task"` 
		timew tag "$client" "$project" $tag_toBeInvoiced "$task"
		report $defaultPeriod
		mainMenu
		return
	fi
	
	
	if [ $action == "p" -o $action == "P" ]
	then
		
		client=$(searchGroupTag cli)
		read -p "${blue}Tag to be replaced${normal} : " task1
		read -p "${blue}New tag${normal}  : " task2
		timew tag $(timew summary 2000-01-01 - 2050-01-01 :ids "$client" "$task1" | awk -F "@" '{if($2!="") print "@"$2}' | awk -F " " '{print $1}' |  tr "\n" " ") "$task2"
		timew untag $(timew summary 2000-01-01 - 2050-01-01 :ids "$client" "$task1" | awk -F "@" '{if($2!="") print "@"$2}' | awk -F " " '{print $1}' |  tr "\n" " ") "$task1"
		
		
		report $defaultPeriod
		mainMenu
		return
	fi
	

	if [ $action == "g" -o $action == "G" ]
	then
		
		read -p "${blue}New tag${normal}  : " task2
		timew tag "$task2"
				
		report $defaultPeriod
		mainMenu
		return
	fi
	
	
	if [ $action == "t" -o $action == "T" ]
	then
		timew stop
		mainMenu
		return
	fi
	
	
	
	
	if [ $action == "r" -o $action == "R" ]
	then
		
		
		report $defaultPeriod
		read -p "${blue}Id to be deleted (ex:1)${normal} : " WhatToDelete
		timew delete @$WhatToDelete
		report $defaultPeriod
		mainMenu
		return
	fi
	
	
	
	if [ $action == "f" -o $action == "F" ]
	then
	
		if ! [ -z "$1" ]
		then
			echo '<!DOCTYPE html><html><head><meta charset="UTF-8" /></head><body><pre>'
		fi
		if ! [ -z "$2" ]
		then
			client=$2
		else
			client=$(searchGroupTag cli)
		fi
		
		
		
		if ! [ -z "$3" ]
		then
			period=$3
		else
			printf "last ${blue}[M]${normal}onth, ${blue}[Q]${normal}uarter, ${blue}[L]${normal}ast quarter or ${blue}[Y]${normal}ear ">&2
			read -rsn1 period
		fi
		
		
		
		if [ $period == "m" -o $period == "M" ]
		then
			period=":lastmonth"
			period_title=$txt_LastMonth
		fi
		if [ $period == "q" -o $period == "Q" ]
		then
			period=":quarter"
			period_title=$txt_ThisQuarter
		fi
		if [ $period == "l" -o $period == "L" ]
		then
			period=":lastquarter"
			period_title=$txt_LastQuarter
		fi
		if [ $period == "y" -o $period == "Y" ]
		then
			
			period=":year"
			period_title=$txt_ThisYear
		fi
		
		if ! [ -z "$4" ]
		then
			invoiced=$4
		else
			printf "\n\nOnly to be invoiced ? ${blue}[Y]${normal}/${blue}[N]${normal}">&2
			read -rsn1 invoiced
		fi
		
		
		if [ $invoiced == "y" -o $invoiced == "Y" ]
		then
			invoiced=$tag_toBeInvoiced
			invoiced_title=$txt_onlyTaskToBeIncoiced
		else
			invoiced=""
			invoiced_title=$txt_allTasks
		fi
		
		
		

		if [ -z "$1" ]
		then
		report $period $client $invoiced
		fi
		timew month :month $client $invoiced | sed "s/Total/ /g" | sed "s/[a-zA-Z_]/-/g" | sed "s/.*/ /g"

		
		  listProj=()
		  listTask=()
		total_global=""
		
		for n in $(timew summary $period $client $invoiced :ids   | awk -F "@" '{if($2!="") print "@"$2}' | sed "s/ ,/,/g" | sed "s/, /,/g"  | sed "s/ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *[0-9]*[0-9]*:[0-9][0-9]*:[0-9][0-9]*//g" | sed "s/@[0-9][0-9]*[0-9]*[0-9]* * * * * * * * * * * * *//g"| sed "s/ /_____/g")
		do
		  
		  IFS="," read -a params <<< $n

		  proj=""
		  task=""

		  for (( i=0; i<=${#params[@]}; i++ )); do
			  if [[ ${params[$i]} =~  [a-zA-Z] ]]; then
				  if ! [[ ${params[$i]} == *"cli:"* ]]; then
					  if ! [[ ${params[$i]} == *$tag_invoiced* ]]; then
						  if ! [[ ${params[$i]} == *$tag_toBeInvoiced* ]]; then
						      if [[ ${params[$i]} == *"proj:"* ]]; then
								 
								 proj=${params[$i]}
							 else
								
								 task+=${params[$i]}
								
								 
							 fi 
						 fi
					  
					  fi
				  
				  fi
			 fi
			  
		  done
		  
		 if [[ $task =~  [a-zA-Z] ]]; then
		  task=$proj"_____'"$task"'"
			
			   
			 if [[ $proj =~  [a-zA-Z] ]]; then
			listProj+=($proj)
			fi

		 
		 
		 
		  	listTask+=($task)
		  fi
		 
		 total_global=$n
		done
		for n in $(timew summary $period $client $invoiced :ids)
		do
		  total_global=$n
		done
		  
		
	
		listProj=( $(
		    for el in "${listProj[@]}"
		    do
		     if [[ $el =~  [a-zA-Z] ]]; then
			echo "$el"
			fi
		    done | sort | uniq) )
		 listTask=( $(
		    for el in "${listTask[@]}"
		    do
		    if [[ $el =~  [a-zA-Z] ]]; then
			echo "$el"
			fi
		    done | sort |uniq) )
		
		
		total_proj=()
		for (( i=0; i<${#listProj[@]}; i++ )); do
		
			for n in $(timew summary $period $client $invoiced ${listProj[$i]} :ids)
			do
			
			 total_proj[i]=$n"_____=_____"${listProj[$i]}
			done

		done
		
		total_task=()
		for (( i=0; i<${#listTask[@]}; i++ )); do
				
			
			
			for n in $(eval "timew summary $period $client $invoiced ${listTask[$i]//"_____"/" "} :ids")
			do
			
			 total_task[i]=$n"_____=_____"${listTask[$i]}
			done
			
		done
		
		
		total_proj=( $(
		    for el in "${total_proj[@]}"
		    do
			echo "$el"
		    done | sort) )
		total_task=( $(
		    for el in "${total_task[@]}"
		    do
			echo "$el"
		    done | sort) )
		
		
		echo ${client//"cli:"/""}" - "$period_title" - "$invoiced_title

		echo "--------"
		echo "$txt_Projects : "
		for (( i=0; i<=${#total_proj[@]}; i++ )); do
			proj=${total_proj[$i]//"_____"/" "}
			proj=${proj//"proj:"/""}
			echo "     "$proj
		done
		echo "--------"
		echo "$txt_Tasks : "
		for (( i=0; i<=${#total_task[@]}; i++ )); do
			task=${total_task[$i]//"_____"/" "}
			task=${task//"proj:"/""}
			echo "     "$task
		done
		
		
		echo "--------"
		echo "$txt_Total : "
		echo "     "$total_global
		if [ -z "$1" ]
		then
			mainMenu
		else
			echo "</pre></body></html>"
		fi
		return
	fi
	
	

		
	
	if [ $action == "e" -o $action == "E" ]
	then
		report $defaultPeriod
		printf "\n\n-----\n">&2
		printf "Edit ${blue}[S]${normal}tart\nEdit ${blue}[E]${normal}nd\nEdit ${blue}[B]${normal}oth (end of first, start of second)\n">&2
		read -rsn1 HowToEdit
		if [ $HowToEdit == "s" -o $HowToEdit == "S" ]
		then
			read -p "${blue}[id] to be modified${normal} : " WhatToEdit
			read -p "${blue}Start time${normal} : " time
			timew modify start @$WhatToEdit $time
			echo "$time">&2
			report $defaultPeriod
			mainMenu
			return
		fi
		if [ $HowToEdit == "e" -o $HowToEdit == "E" ]
		then
			read -p "${blue}[id] to be modified${normal} : " WhatToEdit
			read -p "${blue}End time${normal} : " time
			timew modify end @$WhatToEdit $time
			report $defaultPeriod
			mainMenu
			return
		fi
		if [ $HowToEdit == "b" -o $HowToEdit == "B" ]
		then
			read -p "${blue}First [id] to be modified${normal} : " WhatToEditA
			read -p "${blue}Second [id] to be modified${normal} : " WhatToEditB
			read -p "${blue}Time${normal} : " time
			timew modify end @$WhatToEditA $time
			timew modify start @$WhatToEditB $time
			timew modify end @$WhatToEditA $time
			report $defaultPeriod
			mainMenu
			return
		fi
		mainMenu e
	fi
	period=""
	periodSearch=false
	if [ $action == "d" -o $action == "D" ]
	then
		period=":day"
		defaultPeriod=$period
		periodSearch=true
	fi
	if [ $action == "w" -o $action == "W" ]
	then
		period=":week"
		defaultPeriod=$period
		periodSearch=true
	fi
	if [ $action == "m" -o $action == "M" ]
	then
		period=":month"
		defaultPeriod=$period
		periodSearch=true
	fi
	if [ $action == "y" -o $action == "Y" ]
	then
		period=":year"
		defaultPeriod=$period
		periodSearch=true
	fi
	if [ $periodSearch == true ]
	then
		report $period
		mainMenu
		return
	fi
	
	if [ $action == "c" -o $action == "C" ]
	then
		read -p "${blue}[id] to be continued${normal} : " WhatToContinue
		timew stop
		timew continue @$WhatToContinue
		timew untag $tag_invoiced
		timew tag $tag_toBeInvoiced
	fi
	report $defaultPeriod
	mainMenu
	return
}
if [ -z "$1" ]
		then
	report
fi
mainMenu $1 $2 $3 $3