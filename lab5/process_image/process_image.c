#include "process_image.h"

int process_image(char *input_filename, char *output_filename) {
	int width, height, channels;

	unsigned char *src_image = stbi_load(input_filename, &width, &height, &channels, 0);

	if (!src_image) {
		perror("Error: can't open the image\n");
		return 1;
	}

	unsigned char *gray_image = (unsigned char *)calloc(width*height*3, sizeof(unsigned char));

	for (int i = 0; i < width*height*3; i+=3) {
		unsigned char red = src_image[i];
		unsigned char green = src_image[i+1];
		unsigned char blue = src_image[i+2];

		/* Gray = max(Red, Green, Blue) */
		unsigned char gray = red;
		if (blue > gray) {gray = blue;}
		if (green > gray) {gray = green;}

		gray_image[i] = gray;
		gray_image[i+1] = gray;
		gray_image[i+2] = gray;
	}

	stbi_write_bmp(output_filename, width, height, 3, gray_image);
	free(gray_image);
	stbi_image_free(src_image);

	return 0;
}
