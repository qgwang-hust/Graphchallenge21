#include "utils/matrix.h"
#include "inspector/header.h"
#include <functional>

using namespace ftxj;

int main() {

    std::cout << "begin" << std::endl;

    COOMatrix coo("../data/neuron1024/n1024-l120.tsv", 1);
    std::cout << "coo success" << std::endl;

    coo.save_matrix("tmp1.txt");
    std::cout << "save success" << std::endl;

    HashReorder hash_reorder(64, 1024);
    coo.reorder(hash_reorder);
    std::cout << "reorder success" << std::endl;

    coo.save_matrix("tmp.txt");
    std::cout << "save success" << std::endl;

    CSRCSCMatrix csr_csc(coo);
    std::cout << "csr_csc success" << std::endl;

    // csr_csc.print_one_row(19);
    // csr_csc.print_one_row(20);
    // csr_csc.print_one_row(21);


    BlockContainer blocks(csr_csc, SparseMatrixBlockGen::naive_method);
    std::cout << "block container success" << std::endl;

    return 0;
}