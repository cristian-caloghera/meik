#include <lib.h>

#include <iostream>

int main()
{
  std::cout << "call from static lib returns: " << some_function(7) << "\n";
  return 0;
}
