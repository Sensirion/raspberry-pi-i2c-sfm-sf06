common_sources = sensirion_config.h sensirion_common.h sensirion_common.c
i2c_sources = sensirion_i2c_hal.h sensirion_i2c.h sensirion_i2c.c
sfm_sf06_sources = sfm_sf06_i2c.h sfm_sf06_i2c.c

i2c_implementation ?= sensirion_i2c_hal.c

CFLAGS = -Os -Wall -fstrict-aliasing -Wstrict-aliasing=1 -Wsign-conversion -fPIC -I.

ifdef CI
    CFLAGS += -Werror
endif

.PHONY: all clean

all: sfm_sf06_i2c_example_usage

sfm_sf06_i2c_example_usage: clean
	$(CC) $(CFLAGS) -o $@  ${sfm_sf06_sources} ${i2c_sources} \
		${i2c_implementation} ${common_sources} sfm_sf06_i2c_example_usage.c

clean:
	$(RM) sfm_sf06_i2c_example_usage