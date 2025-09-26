#################################################
#               A completer !                   #
#                                               #
# Nom et prenom binome 1 : Dumangin Noah        #
# Nom et prenom binome 2 : Sihr Victor          #
#################################################


# ===== Section donnees =====  
.data
    filename: .asciiz "/Users/victor/Cours/SAE_Assembleur/sudoku.txt" #chemin absolue du fichier
    buffer: .space 81
    grille: .space 82
    squares: .byte 0,3,6,27,30,33,54,57,60
    offsets: .byte 0,1,2,9,10,11,18,19,20


# ===== Section code =====  
.text
# ----- Main ----- 

main:
    jal parseValues
    jal transformAsciiValues
    jal solve_sudoku  
    jal displayGrille
    j exit

# ----- Fonctions ----- 


# ----- Fonction addNewLine -----  
# objectif : fait un retour a la ligne a l'ecran
# Registres utilises : $v0, $a0
addNewLine:
    li $v0, 11
    li $a0, 10
    syscall
    jr $ra #revient la ou on était



# ----- Fonction displayGrille -----   
# Affiche la grille.
# Registres utilises : $v0, $a0, $t[0-2]
displayGrille:  
    la $t0, grille
    add $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw $ra, 0($sp)
    li $t1, 0
    boucle_displayGrille:
        bge $t1, 81, end_displayGrille     # Si $t1 est plus grand ou egal a 81 alors branchement a end_displayGrille
            add $t2, $t0, $t1           # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            lb $a0, ($t2)              # load byte at $t2(adress) in $a0
            li $v0, 1                  # code pour l'affichage d'un entier
            syscall
            add $t1, $t1, 1             # $t1 += 1;
            #ajouter les |
   	    move $a0, $t1                         # $a0 = $t1 pour le modulo
    	    li $a1, 9                           # $a1 = 9 (modulo 9)
    	    jal getModulo                        # Appelle la fonction de modulo
    	    beqz $v0, addNewLine
    	    li $a1, 3
 	    jal getModulo
    	    beqz  $v0 addPipe
    	    #ajouter les - 
    	    move $a0, $t1
    	    li $a1, 27                 # $a1 = 27 (modulo 27)
    	    jal getModulo
    	    beqz $v0, addDash
    	    j boucle_displayGrille
    	      
    end_displayGrille:
        lw $ra, 0($sp)                 # On recharge la reference 
        add $sp, $sp, 4                 # du dernier jump
    jr $ra

# ----- Fonction transformAsciiValues -----   
# Objectif : transforme la grille de ascii a integer
# Registres utilises : $t[0-3]
transformAsciiValues:  
    add $sp, $sp, -4
    sw $ra, 0($sp)
    la $t3, grille
    li $t0, 0
    boucle_transformAsciiValues:
        bge $t0, 81, end_transformAsciiValues
            add $t1, $t3, $t0
            lb $t2, ($t1)
            sub $t2, $t2, 48
            sb $t2, ($t1)
            add $t0, $t0, 1
        j boucle_transformAsciiValues
    end_transformAsciiValues:
    lw $ra, 0($sp)
    add $sp, $sp, 4
    jr $ra


# ----- Fonction getModulo ----- 
# Objectif : Fait le modulo (a mod b)
# $a0 represente le nombre a (doit etre positif)
# $a1 represente le nombre b (doit etre positif)
# Resultat dans : $v0
# Registres utilises : $a0
getModulo: 
    sub $sp, $sp, 4
    sw $ra, 0($sp)
    boucle_getModulo:
        blt $a0, $a1, end_getModulo
            sub $a0, $a0, $a1
        j boucle_getModulo
    end_getModulo:
    move    $v0, $a0
    lw      $ra, 0($sp)
    add     $sp, $sp, 4
    jr $ra

# ----- Fonction check_n_column -----   
# verifie la n-ième colonne
#Fonction check_n_column:
check_n_column:
    add    $sp $sp -4
    sw     $ra 0($sp)
    add    $sp $sp -10    #abaisse la pile de 10

    li    $t9 0        #$t9 : i=0
    boucle_byte_column:        #remplit la pile de 9 zeros
    bge    $t9 10 suite_column
        add     $t8 $sp $t9        #$t8: la case a l'indice
        sb    $zero    ($t8)    #on met un zero a la case d'indice $t8
        addi    $t9 $t9 1        #incremente $t9
        j    boucle_byte_column

    suite_column:
        li    $v0, 1            # $v0: unique=1 (vrai)
        move    $t1 $a0

    boucle_check_n_column:
        bge     $t1 81 end_check_n_column    # tant que i<81 (taille max)
            add     $t2 $t0 $t1        # $t2 : indice du nombre
            lb     $t3, ($t2)        # $t3 : valeur du nombre

            add     $t8 $sp $t3    # $t8 l'indice corespondant à la case $t3 dans la pile
            lb    $a2    ($t8)    # valeur a l'indice $t8
            bgtz    $a2 double_column    #Si c'est different de zero alors la valeur est en double
            sb    $t3    ($t8)    #sinon on marque sa présence dans la pile
               addi     $t1, $t1, 9    #incremente $t1
            j     boucle_check_n_column

        double_column:
            li    $v0, 0

    end_check_n_column:
    add $sp $sp 10
        lw     $ra 0($sp)
        add     $sp $sp 4
        jr     $ra

# ----- Fonction check_n_row -----   
# vérifie la n_ième ligne
check_n_row:
    add    $sp $sp -4
    sw     $ra 0($sp)
    add    $sp $sp -10    #abaisse la pile de 10

    li    $t9 0        #$t9 : i=0
    boucle_byte_row:        #remplit la pile de 9 zeros
    bge    $t9 10 suite_row
    add     $t8 $sp $t9        #$t8: la case a l'indice
    sb    $zero    ($t8)        #on met un zero a la case d'indice $t8
    add    $t9 $t9 1        #incremente $t9
    j    boucle_byte_row

    suite_row:
    mul     $t1 $a0 9    #t1 : i = premier indice à la ligne $a0
    addi     $a0 $t1 9    # a0 = i + 9 pour parcourir uniquement 9 fois dans la boucle
    li    $v0, 1
    boucle_check_n_row:
            bge     $t1 $a0 end_check_n_row    # tant que i<81 (taille max)
            add     $t2 $t0 $t1        # $t2 : indice du nombre
            lb     $t3, ($t2)        # $t3 : valeur du nombre

            add     $t8 $sp $t3
            lb    $a2    ($t8)

            bgtz    $a2 doubler    #si différent de 0 = doublon
            sb    $t3 ($t8)    #sinon on marque sa présence dans la pile
               addi     $t1, $t1, 1
            j     boucle_check_n_row
 
        doubler:
        li    $v0, 0

    end_check_n_row:
    add $sp $sp 10
        lw     $ra 0($sp)
        add     $sp $sp 4
        jr     $ra

# ----- Fonction check_n_square -----   
# vérifie le n-ième carré
# la grille est dans t0
# le n carre est dans a0
# Résultat dans $v0 (0 ou 1 si juste)
#Registres utilisés : t[1-3]+t[8-9]+a2
check_n_square:
    add    $sp $sp -4
    sw     $ra 0($sp)
    add    $sp $sp -10
    
    li     $t9 0
    boucle_byte_square:        #rempli la pile avec 9 zeros
    bge    $t9 10 suite_square
        add     $t8 $sp $t9
        sb    $zero ($t8)
        addi     $t9 $t9 1
        j    boucle_byte_square
    suite_square:
    li     $v0 1        #resultat = true
    li     $t9 0        #t9 : i
    la    $t1 squares    
    add     $t1 $a0 $t1
    lb    $t1 ($t1)        #t1 : indice du premier carre
    add    $t1 $t1 $t0        #t1 : adresse du premier carre
    boucle_check_n_square:
    bge    $t9 9 end_check_n_square    
        la    $t3 offsets
        add    $t3 $t3 $t9
        lb    $t3 ($t3)    #t3 : decalage à effectuer
        add    $t3 $t3 $t1    #t3 : adresse courante
        lb    $t3 ($t3)    #t3 : valeur de la case de la grille
        
        add    $t8 $sp $t3    #t8 : adresse de Pile[t3]
        lb    $a2 ($t8)    #a2 : valeur de Pile[t3]
        bgtz    $a2 double_square    # si different de 0 (doublon)
        sb    $t3 ($t8)        #sinon on marque sa présence dans la pile
        
        addi     $t9 $t9 1
        j    boucle_check_n_square
    double_square:
    li     $v0 0
        
    end_check_n_square:
    add     $sp $sp 10
        lw     $ra 0($sp)
        add     $sp $sp 4
        jr     $ra

# ----- Fonction check_column -----   
# vérifie toutes les colonnes 
check_columns:
    add    $sp $sp -4
    sw     $ra 0($sp)
    li $a0, 0
    boucle_columns:
    	bge $a0, 8, end_check_columns
    	jal check_n_column
    	add $a0, $a0, 1
    	
    j boucle_columns
    end_check_columns:
    	lw     $ra 0($sp)
        add     $sp $sp 4
        jr     $ra

	  
# ----- Fonction check_rows -----   
# vérifie toutes les lignes 
check_rows:
    add    $sp $sp -4
    sw     $ra 0($sp)
    li $a0, 0
    boucle_rows:
    	bge $a0, 8 end_check_rows
    	jal check_n_row
    	add $a0, $a0, 1

    j boucle_rows
    end_check_rows:
    	lw     $ra 0($sp)
        add     $sp $sp 4
        jr     $ra
    
# ----- Fonction check_squares -----   
# vérifie tous les carrés du sudoku
check_squares:
    add    $sp $sp -4
    sw     $ra 0($sp)
    li $a0, 0
    boucle_squares:
    	bge $a0, 8 end_check_squares
    	jal check_n_square
    	add $a0, $a0, 1
    j boucle_squares
    
    end_check_squares:
    	lw     $ra 0($sp)
        add     $sp $sp 4
        jr     $ra
    
# ----- Fonction check_sudoku -----   
# véérifie le sudoku en entier 
check_sudoku:
    add    $sp $sp -4
    sw     $ra 0($sp)
    jal check_squares
    jal check_columns
    jal check_rows

    lw     $ra 0($sp)
    add     $sp $sp 4
    jr     $ra
	
# ----- Fonction solve_sudoku -----   
# permet de tester les solutions du sudoku   
solve_sudoku:
    add    $sp $sp -4
    sw     $ra 0($sp)
    li $t6, 1
    
find_empty:    
    la $t0, grille      
    li      $t1, 0                   # Initialiser l'index (case 0)
find_loop:
    bge     $t1, 81, no_empty        # Si on a parcouru toute la grille, retourner 0 (aucune case vide)
    lb      $t2, 0($t0)              # Charger la valeur de la case
    beq     $t2, $zero, found_empty  # Si la case est vide (0), retourner l'index
    addi    $t1, $t1, 1              # Passer à la case suivante
    addi    $t0, $t0, 1
    j find_loop
    
no_empty:
    li      $v0, 1
    j solve_end
    
found_empty:
    move $a3, $t1
    j try_number
    
try_number:
    la $t3, grille
    bgt     $t6, 9, solve_failed
    
    add $t4, $t3, $a3
    sb $t6, ($t4)
    jal Grille
    
    jal check_sudoku
    beqz    $v0, try_next_number
    
    jal solve_sudoku
    beqz    $v0, try_next_number
    
    li      $v0, 1
    j       solve_end
    
solve_failed:
    li      $v0, 0
    
solve_end:
    lw      $ra, 0($sp)
    addi    $sp, $sp, 4
    jr      $ra
    
try_next_number:
    la $t3, grille
    add $t4, $t3, $a3
    
    sb $zero, ($t4)
    la $t3, grille
    
    add $t6, $t6, 1
    j try_number
    
    lw     $ra 0($sp)
    add     $sp $sp 4
    jr     $ra

# ----- Fonction loadFile -----   
# permet de charger le sudoku pour pouvoir le résoudre ensemble
loadFile:
    addi $v0, $zero, 13             # syscall 13 (open)
    la   $a0, filename              # Nom du fichier
    addi $a1, $zero, 0              # Mode lecture seule
    addi $a2, $zero, 0              # Aucun mode spécial
    syscall                         # Appel système pour ouvrir le fichier
    move $t0, $v0
    jr $ra
	
# ----- Fonction closeFile -----   
close_file:
	li $v0, 16	
	syscall
	jr $ra

# ----- fonction parseValues -----
parseValues:
#Lis la grille contenue dans le fichier
    add     $sp, $sp, -4
    sw      $ra, 0($sp)
    jal loadFile
    li $t3, 0
    la $t4, grille

    boucle_parse:
    beq $t3, 81, end_parse
    move $a0, $t0                   # Descripteur de fichier
    la   $a1, buffer 
    addi $a2, $zero, 1              # Lire un caractère à la fois
    addi $v0, $zero, 14             # syscall 14 (read)
    syscall
    
    lb $t2, 0($a1)         # Charger le caractère actuel du tampon
    sb $t2, 0($t4)         # Stocker ce caractère dans la grille
    
    addi $a0, $a0, 1       # Incrémenter l'adresse du tampon
    addi $t4, $t4, 1       # Incrémenter l'adresse de la grille
    
    addi $t3, $t3, 1
    j boucle_parse

end_parse:
    jal close_file
    lw      $ra, 0($sp)
    addi    $sp, $sp, 4
    jr      $ra

# ----- Fonction zeroToSpace -----   
# permet de remplacer tout les zeros par des espaces
zeroToSpace:
	li $t0, 0                  # Initialiser le compteur (index de la case) à 0
	la $t1, grille              # Charger l'adresse de base de la grille
	boucle_zeroToSpace:
		bge $t0, 81, fin_zeroToSpace  # Si toutes les 81 cases ont été vérifiées, terminer
		lb $t2, 0($t1)             # Charger la valeur de la case actuelle dans $t2
		beq $t2, $zero, remplace_par_espace  # Si la case est 0, la remplacer par un espace
		addi $t0, $t0, 1           # Passer à la case suivante
		addi $t1, $t1, 1           # Avancer dans la grille (1 octet par case)
		j boucle_zeroToSpace       # Revenir à la boucle
	remplace_par_espace:
		li $t3, 32                 # Charger la valeur ASCII de l'espace (32) dans $t3
		# Remplacer par espace (utiliser sw pour stocker un mot de 32 bits)
		li $t7, 0                  # Créer un mot de 32 bits pour remplacer 0 avec un espace (32)
		or $t7, $t7, $t3           # Mettre l'espace dans les 8 premiers bits de $t7
		sw $t7, 0($t1)             # Remplacer le 0 par un espace (32) dans la grille
		addi $t0, $t0, 1           # Passer à la case suivante
		addi $t1, $t1, 1           # Avancer dans la grille (1 octet par case)
	j boucle_zeroToSpace       # Revenir à la boucle
	fin_zeroToSpace:
		jr $ra                     # Retour à l'appelant

# ----- Fonction displaysudoku -----   
# permet d'afficher les solutions des sudokus
displaysudoku:  
    la      $t0, grille
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)
    li      $t1, 0
    boucle_displaysudoku:
        bge     $t1, 81, end_displaysudoku     # Si $t1 est plus grand ou egal a 81 alors branchement a end_displayGrille
            add     $t2, $t0, $t1           # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            lb      $a0, ($t2)              # load byte at $t2(adress) in $a0
            li      $v0, 1                  # code pour l'affichage d'un entier
            syscall
            add     $t1, $t1, 1             # $t1 += 1;
            #ajouter les |
   	    move    $a0, $t1                         # $a0 = $t1 pour le modulo
    	    li      $a1, 9                           # $a1 = 9 (modulo 9)
    	    jal     getModulo                        # Appelle la fonction de modulo
    	    beqz    $v0, addNewLine
    	    li $a1, 3
 	    jal getModulo
    	    beqz  $v0 addPipe
    	    #ajouter les - 
    	    move    $a0, $t1
    	    li      $a1, 27                 # $a1 = 27 (modulo 27)
    	    jal     getModulo
    	    beqz    $v0, addDash
    	    j boucle_displaysudoku
    	      
    end_displaysudoku:
        lw      $ra, 0($sp)                 # On recharge la reference 
        add     $sp, $sp, 4                 # du dernier jump
    jr $ra

# Autres fonctions que nous avons ajoute :  
# ----- Fonction addPipe -----   
# permet d'ajouter dans l'affichage le symbole | pour délimiter la grille   
addPipe:
    	li $v0, 11	#permet d'afficher un caractère
    	li $a0, '|'	#initialise a0 avec le pipe
    	syscall
    	j boucle_displayGrille    #retourne a la boucle display grille

# ----- Fonction addDash -----   
# permet d'ajouter dans l'affichage le symbole - pour délimiter la grille   
addDash:   
	li      $t3, 0                  # Initialisation du compteur de tirets
	boucle_addDash:
   		li      $v0, 11                 # Code pour afficher un caractère
    		li      $a0, '-'                # Affiche directement le caractère '-'
    		syscall
    		add     $t3, $t3, 1             # Incrémentation du compteur de tirets
    		bne     $t3, 11, boucle_addDash # Répéter tant que 11 tirets ne sont pas affichés
    		jal     addNewLine		#passe à la ligne après les 11 tirets
    		j       boucle_displayGrille    # Retour à la boucle display grille                                 

# ----- Fonction Grille -----   
# permet de parcourir la grille 
Grille:  
    la      $t0, grille
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)
    li      $t1, 0
    boucle_Grille:
        bge     $t1, 81, end_Grille     # Si $t1 est plus grand ou egal a 81 alors branchement a end_displayGrille
        add     $t2, $t0, $t1           # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
        lb      $a0, ($t2)
        add $t1, $t1, 1
    end_Grille:
    lw     $ra 0($sp)
        add     $sp $sp 4
        jr     $ra
    

exit: 
    li $v0, 10
    syscall
