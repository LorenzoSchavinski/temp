#!/bin/bash

# Diretório de saída
OUTPUT_DIR="output"
mkdir -p "$OUTPUT_DIR"

# Função para a versão sequencial
run_sequential() {
    echo "Compilando a versão sequencial..."
    gcc mandelbrot.c -o mandelbrot_seq -lm
    if [ $? -eq 0 ]; then
        echo "Executando a versão sequencial..."
        srun --nodes=1 --ntasks=1 ./mandelbrot_seq
        echo "Resultado salvo em $OUTPUT_DIR/ms.ppm"
    else
        echo "Erro ao compilar a versão sequencial."
    fi
}

# Função para a versão OpenMP
run_openmp() {
    local cpus=$1
    echo "Compilando a versão OpenMP..."
    gcc parallel/mandelbrot_openmp.c -o mandelbrot_omp -fopenmp -lm
    if [ $? -eq 0 ]; then
        echo "Executando a versão OpenMP com $cpus CPUs..."
        srun --nodes=1 --ntasks=1 --cpus-per-task=$cpus ./mandelbrot_omp
        echo "Resultado OpenMP com $cpus CPUs salvo em $OUTPUT_DIR"
    else
        echo "Erro ao compilar a versão OpenMP."
    fi
}

# Função para a versão MPI
run_mpi() {
    echo "Compilando a versão MPI..."
    mpicc parallel/mandelbrot_mpi.c -o mandelbrot_mpi -lm
    if [ $? -eq 0 ]; then
        echo "Executando a versão MPI com 2 nós e 16 tarefas..."
        srun --nodes=2 --ntasks=16 ./mandelbrot_mpi
        echo "Resultado MPI salvo em $OUTPUT_DIR"
    else
        echo "Erro ao compilar a versão MPI."
    fi
}

# Execução
echo "Iniciando a geração do fractal Mandelbrot..."
run_sequential

# Execuções com OpenMP para diferentes números de CPUs
run_openmp 8
run_openmp 10
run_openmp 12
run_openmp 14
run_openmp 16

# Execução com MPI
run_mpi

echo "Processo concluído."
