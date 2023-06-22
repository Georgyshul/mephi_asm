#ifndef LAB5_PROCESS_IMAGE_PROCESS_IMAGE_H_
#define LAB5_PROCESS_IMAGE_PROCESS_IMAGE_H_

#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION

#include <stdio.h>
#include <stdlib.h>
#include "stb/stb_image.h"
#include "stb/stb_image_write.h"

int process_image(char *input_filename, char *output_filename);

#endif  // LAB5_PROCESS_IMAGE_PROCESS_IMAGE_H_