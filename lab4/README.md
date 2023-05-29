# Лабораторная работа № 4 «Обработка вещественных чисел»

## Введение

Необходимо спроектировать и разработать на языке Ассемблера программу, осуществляющую
вычисление значения функции в точке при помощи разложения в ряд с использованием чисел с плавающей точкой одинарной или
двойной точности.

### Примечания

1. Программа должна использовать функции из библиотеки libc, в случае необходимости, libm.
1. Прямое использование программой системных вызовов запрещено.
1. Для ввода/вывода необходимо использовать функции стандартной библиотеки языка C с корректными спецификаторами
   формата:
    - `%d` — для целых чисел;
    - `%f` — для чисел с плавающей точкой одинарной точности;
    - `%lf` — для чисел с плавающей точкой двойной точности.
1. Программа должна считывать входные данные из стандартного потока ввода, итоговые результаты вычислений помещать в
   стандартный поток вывода, а результаты вычислений членов ряда, с указанием их номеров, записывать в текстовый файл.
1. Имена файлов должны передаваться программе через параметры командной строки.
1. Программа должна соблюдать соглашение о вызове (calling convention) для всех подпрограмм,
   в т. ч. и для внутренних.
1. Программа должна обеспечить корректную обработку ошибок, обеспечив вывод соответствующих сообщений и корректное
   завершение работы.

## Задание

Вычислить значение функции в точке при помощи разложения в ряд:

$$ (\frac{\arcsin x}{x})^2=1+\frac{2^3(1!)^2x^2}{4!}+\frac{2^5(2!)^2x^4}{6!}+...=\sum_{n=0}^{\infty}\frac{2^{2n+1}(n!)
^2}{(2n+2)!}x^{2n} $$

где $ |x| \le 1 $

## Способы ввода и вывода данных

- Ввод: значение $x$, точность
- Вывод: значения функции, полученные путём вычисления левой и правой части равенства

## Тип данных, используемый для работы с вещественными числами

Число с плавающей точкой двойной точности.

## Запуск программы

```./lab <filename>```

## Передаваемые параметры

x - аргумент ```asin(x)```, двойная точность;
n - точность. Вычисляются члены ряда $ s_i $ пока $ |s_i| \ge 10^{-n} $


