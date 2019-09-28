Instruction
-----------

EBE<sub>APML0</sub> is a high-throughput machine learning approach for
multivariate dynamic GWAS.

#### The source codes and examples are available [**Here**](https://github.com/Myuan2019/EBE_APML0).

Requirements
------------

EBE<sub>APML0</sub> requires the following R packages:

-   `nlme`, `APML0`

You could download them directly in CRAN through the following commands
in your R console.

    install.packages(c('nlme', 'APML0'))

To perform EBE<sub>LASSO</sub>, R package 'glmnet' is also needed.

Usage
-----

-   `ebel0.R` is the main program to perform each method.
-   `data.RData` is a sample data of traits and time.
-   `datax.RData` is a sample data of genotype.

### Input

-traits and time: each row representing a sample at a time point; the
four columns representing the patient ID, the measuring time points, the
patient ID (reserved) and the traits, respectively.

    load('data.RData')
    head(myData)

    ##   ID Time ID2        DV
    ## 1  1    1   1 0.7202856
    ## 2  1   14   1 0.4608144
    ## 3  1   27   1 0.4817815
    ## 4  1   40   1 0.9401994
    ## 5  1   53   1 0.6094163
    ## 6  1   66   1 0.5832650

-genotype: a large N by p matrix with each row representing an
individual; each column representing an SNP

### Output

<<<<<<< HEAD
-The results of EBE<sub>LASSO</sub> and EBE<sub>APML0</sub> are output
as a list named as follows:
=======
-The results are output as a list. 6 methods including
EBE<sub>Enet</sub>, EBE<sub>LASSO</sub> and EBE<sub>APML0</sub> are
introduced in the example. For the generally used EBE<sub>APML0</sub>
method, we take lasso as the convex function. However, more choices such
as elastic net and selection combined with BIC are also shown in the
example.They are named as follows:
>>>>>>> 8973389aed595a805e25f39b450add34ca5bf5a5

    resl<-EBEL0(myData,myData_x)
    names(resl)

<<<<<<< HEAD
    ## [1] "lasso" "apml0"
=======
    ## [1] "enet"       "lasso"      "l0enet"     "l0enetbic"  "l0lasso"   
    ## [6] "l0lassobic"
>>>>>>> 8973389aed595a805e25f39b450add34ca5bf5a5

-For each method, computational time, selected SNPs and their weight are
reported. Take EBE<sub>APML0</sub> as an example, the first number is
the computational time, the next half numbers are the serial number of
the selected SNPs and the last half are their weight respectively.

<<<<<<< HEAD
    resl$apml0

    ##      elapsed                                                     
    ## 1.400000e-01 2.000000e+00 5.000000e+01 1.417247e-04 1.405635e-04
=======
    resl$l0lasso

    ##      elapsed                                                     
    ## 1.300000e-01 2.000000e+00 5.000000e+01 1.417247e-04 1.405635e-04
>>>>>>> 8973389aed595a805e25f39b450add34ca5bf5a5
