transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+D:/yyyyyyyyy/studia/semestr\ X/PKUC\ II/projekt/EDDSAv2/HDL/primitives/arithmetic {D:/yyyyyyyyy/studia/semestr X/PKUC II/projekt/EDDSAv2/HDL/primitives/arithmetic/add.sv}

