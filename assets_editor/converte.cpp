#include <iostream>
#include <fstream>
using namespace std;

int main()
{
    ofstream myfile;
    ifstream in("./assets/prologue - Copia.txt", ios_base::in);
    myfile.open("./assets/prologue.txt");
    string line;
    while (getline(in, line))
    {
        
        myfile << line << endl;
    }
    myfile.close();
}