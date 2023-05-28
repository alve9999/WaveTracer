#include <iostream>
#include <math.h>
#include <SFML/Graphics.hpp>
#include <thrust/complex.h>
#include <stdlib.h>
#include <iostream>
#include "defines.h"
void CUDA_INIT();
void get_colour(uint8_t* pixel_buffer);

void apply_light(double x, double y);

int main()
{
    CUDA_INIT();
    bool* blockers = new bool[nx * ny];
    for (int i = 0; i < ny; i++) {
        for (int j = 0; j < nx; j++) {
            //if (std::sqrt((pow((j-nx / 2), 2) + pow((i-ny / 2), 2))) < 50) {
            //    blockers[i * ny + j] = true;
            //}
            //if (std::abs(ny/2-i)<40 && (std::abs(nx / 2 - j-100) < 20 || std::abs(nx / 2 - j + 100)<20)) {
            //    blockers[i * ny + j] = true;
            //}
            if (std::abs(ny/2-i)<20 && (std::abs(nx / 2 - j-100) < 20)) {
                blockers[i * ny + j] = true;
            }

            else {
                blockers[i * ny + j] = false;
            }

        }
    }


    for (int i = 0; i < ny; i++) {
        for (int j = 0; j < nx; j++) {
            if (blockers[i * ny + j]) {
                apply_light(inscale* (x_off + j), inscale*(y_off + i));
            }
        }
    }



    sf::RenderWindow window(sf::VideoMode(nx, ny), "Light");
    sf::Texture texture;
    sf::Sprite sprite;

    sf::Uint8* pixel_buffer;
    pixel_buffer = (sf::Uint8*)malloc(4 * nx * ny * sizeof(sf::Uint8*));

    get_colour(pixel_buffer);
    texture.create(ny, nx);
    texture.update(pixel_buffer);
    sprite.setTexture(texture);
    window.draw(sprite);
    window.display();
    sf::Event event;
    while (1) {
        window.pollEvent(event);

    }
}

