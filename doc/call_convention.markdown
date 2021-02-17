## parameter
### 1. the way of passing parameters    
In x86(i386) platform,we use stack to pass parameters when invoke function.
Example1.1:
```c
    int (int a,int b);
```
The above function
## register
- ### registers stored by caller: EAX, ECX, EDX.
- ### registers stored by function: EBX, EDI,ESI 
