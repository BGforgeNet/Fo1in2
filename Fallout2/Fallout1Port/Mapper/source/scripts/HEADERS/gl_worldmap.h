#ifndef GL_WORLDMAP_H
#define GL_WORLDMAP_H

#define WM_TERRAIN_UNKNOWN  (0)
#define WM_TERRAIN_CITY     (1)
#define WM_TERRAIN_DESERT   (2)
#define WM_TERRAIN_MOUNTAIN (3)
#define WM_TERRAIN_OCEAN    (4)

#define is_terrain_desert 				(global_var(WORLD_TERRAIN_TYPE) == WM_TERRAIN_DESERT)
#define is_terrain_city 				(global_var(WORLD_TERRAIN_TYPE) == WM_TERRAIN_CITY)
#define is_terrain_mountain 			(global_var(WORLD_TERRAIN_TYPE) == WM_TERRAIN_MOUNTAIN)
#define is_terrain_ocean 				(global_var(WORLD_TERRAIN_TYPE) == WM_TERRAIN_OCEAN)

#endif // GL_WORLDMAP_H //