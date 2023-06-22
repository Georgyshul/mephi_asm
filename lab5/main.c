#include <stdio.h>
#include <time.h>

extern int process_image(char *input_filename, char *output_filename);

int main(int argc, char *argv[]) {
	double time_spent = 0.0;
	clock_t begin = clock();

	int exit_code;
	if (argc != 3) {
		printf("Usage: %s <input file> <output file>\n", argv[0]);
		exit_code = 1;
	} else {
		exit_code = process_image(argv[1], argv[2]);
	}

	clock_t end = clock();

	time_spent += (double)(end - begin) / CLOCKS_PER_SEC;
	printf("Execution time: %f seconds", time_spent);

	return exit_code;
}
