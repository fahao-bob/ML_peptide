#!/bin/bash


set -e
#########################################
### output  coord.txt####################
#########################################
echo -n "import the name of gif> "
read a

### Delete all blank lines, and output lines(>6)
sed '/^\s*$/d' ${a}.gjf | awk 'NR>6' > temp11.txt

### Edit format
awk '{print "                              ""["$2","$3","$4"]"}' temp11.txt > temp12.txt
echo   "coordinates = torch.tensor([["`head -1 temp12.txt`> temp13.txt 
cat temp13.txt temp12.txt >> temp14.txt
sed -i "2d" temp14.txt

a=`wc -l temp14.txt|awk '{print $1}'`
sed -i "${a}s/$/]]/" temp14.txt

### add , at the at the end of each line ###
sed -i 's/$/,/' temp14.txt
echo -e     "                              requires_grad=True, device=device)\n" >> temp14.txt
mv temp14.txt coord.txt
rm -r temp1?.txt
echo " the transformation of coordinate is ok"



#########################################
### output  species.txt##################
#########################################
echo -n "import the name of gjf > "
read a

### Delete all blank lines, and output lines(>6)
sed '/^\s*$/d' ${a}.gjf | awk 'NR>6' > temp21.txt

### Edit format
awk '{print $1}' temp21.txt > temp22.txt

#awk '{printf $1}' temp21.txt > temp23.txtcat temp21.txt |awk '{print $1}'|xargs|sed 's/ /,/g'
a=`wc -l temp21.txt|awk '{print $1}'`
for((i=1;i<=${a};i++))
do
	b=`sed -n "${i}p" temp22.txt`
	if   [ $b = "H" ]
	then
		echo -e 1 >> temp23.txt
	elif [ $b = "C" ]
	then	
		echo -e 6 >> temp23.txt
	elif [ $b = "N" ]
	then	
		echo -e 7 >> temp23.txt   	
	elif [ $b = "O" ]
	then	
		echo -e 8 >> temp23.txt
	elif [ $b = "S" ]
	then	
		echo -e 16 >> temp23.txt
	fi
done

### add , to the last of every  line
sed -i "s/$/,/" temp23.txt

### convert the column to line
cat temp23.txt |xargs >> temp24.txt

### delete the last character, 
cat temp24.txt|rev|sed 's/,/ /'|rev >> temp25.txt

sed -i "s/^/species = torch.tensor([[/" temp25.txt
sed -i "s/$/]], device=device)/" temp25.txt
cp temp25.txt species.txt
rm -r temp2?.txt
echo " the transformation of species is ok"



#########################################
### merge              ##################
#########################################
echo -n "Outpu .py for ANI > "
read a

cat > ${a}.py << _EOF_
# -*- coding: utf-8 -*-

import torch
import torchani

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

model = torchani.models.ANI1x(periodic_table_index=True).to(device)

_EOF_

cat coord.txt species.txt >> ${a}.py

cat >> ${a}.py << _EOF_

energy = model((species, coordinates)).energies
derivative = torch.autograd.grad(energy.sum(), coordinates)[0]
force = -derivative

print('Energy:', energy.item())
print('Force:', force.squeeze())

_EOF_

rm -r coord.txt
rm -r species.txt
echo " the outpu ${a}.py is ok"
 
