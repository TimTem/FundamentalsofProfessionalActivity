    ORG     0x000 ;инициализация векторов прерываний
V0: WORD    $DEFAULT, 0x180
V1: WORD    $INT1, 0x180 ;Вектор прерываний для ВУ 1
V2: WORD    $INT2, 0x180    ;Вектор прерываний для ВУ 2
V3: WORD    $DEFAULT, 0x180 
V4: WORD    $DEFAULT, 0x180 
V5: WORD    $DEFAULT, 0x180 
V6: WORD    $DEFAULT, 0x180 
V7: WORD    $DEFAULT, 0x180 
    ORG 0x02D   
X:  WORD    0x0000  ;Переменная X
MIN: WORD   0xFFEB  ;Нижняя граница значений X
MAX: WORD   0x0015  ;Верхняя граница значений X
DEFAULT:    IRET        ;Обработка прерывания по умолчанию
X_ADDRESS: WORD $X
TEMP: WORD ?
START:  DI
    CLA
    LD #0x8 ;загрузка в аккумулятор MR (1000)
    ADD #0x3 ;загрузка в аккумулятор MR (1000|0011=1011)
    OUT 3 ;разрешение прерываний для 1 ВУ
    LD #0x8 ;загрузка в аккумулятор MR (1000)
    ADD #0x5 ;загрузка в аккумулятор MR (1000|0101=1101)
    OUT 5 ;разрешение прерываний для 2 ВУ
    EI
MAIN:   
    EI
    LD X
    ST TEMP
    INC
    CALL CHECK
    PUSH
    LD TEMP
    PUSH
    LD X_ADDRESS
    PUSH
    CALL $CAS
    JUMP MAIN



INT1: ;обработка прерывания на ВУ-1
    PUSH
    LD X
    ASL
    ADD X
    ASL
    INC
    INC
    NEG
    OUT 2
    LD X
    NOP
    
    SWAP
    POP

    IRET
    



INT2: ;обработка прерывания на ВУ-2
    PUSH
    NOP
    IN 4
    AND X
    ST X
    NOP
    
    SWAP
    POP

    IRET

CHECK:  ;Проверка принадлежности X к ОДЗ
CHECK_MIN:  
    CMP MIN ;если x > MIN переход на проверку верхней границы
    BPL CHECK_MAX   
    JUMP LD_MIN ;иначе загрузка MIN в аккумулятор
CHECK_MAX:  
    CMP MAX ;Проверка пересечения верхней границы X
    BMI RETURN  ;если x<MAX возврат
LD_MIN: 
    LD MIN ;Загрузка минимального значения в X  
RETURN: RET ;Метка возврата из проверки на ОДЗ  

DEREF: WORD ?

CAS:
    PUSHF
    DI
    LD &2
    ST DEREF
    LD (DEREF)
    CMP &3
    BNE FAIL


SUCCES: LD &4
    ST (DEREF)
    LD #0x1
    JUMP EXIT

FAIL:CLA

EXIT: POPF
SWAP
ST &3
SWAP
SWAP
POP
SWAP
POP
SWAP
POP
RET
; RET 1- новое  0 - старое

