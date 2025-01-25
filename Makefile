
NAME := executable_name
.DEFAULT_GOAL := all
CPP := cc
AR := ar
RM := rm -rf

################################################################################
###############                  DIRECTORIES                      ##############
################################################################################

OBJ_DIR := _obj
# INC_DIRS := .
INC_DIRS := Includes
# SRC_DIRS := .
SRC_DIRS := src
# SRC_DIRS := src src/Extra src/Tests --> for subfolders note like that

# Tell the Makefile where headers and source files are
vpath %.h $(INC_DIRS)
vpath %.c $(SRC_DIRS)

################################################################################
###############                  SOURCE FILES                     ##############
################################################################################

MAIN_FILE := main.c

SRC_SUBREPO_FILES := subrepo_file.c
SRC_SUBREPO := $(addprefix subrepo/, $(SRC_SUBREPO_FILES))

SRC :=	test.c
SRCS := $(MAIN_FILE) $(addprefix src/, $(SRC) $(SRC_SUBREPO))

OBJS := $(addprefix $(OBJ_DIR)/, $(SRCS:%.c=%.o))

################################################################################
########                         COMPILING                      ################
################################################################################

CFLAGS := -Wall -Werror -Wextra -Wconversion -Wsign-conversion -g -MMD -MP $(addprefix -I, $(INC_DIRS))
CFLAGS_SAN := $(CFLAGS) -fsanitize=address
LDFLAGS := -lncurses
LDFLAGS_SAN := -lncurses -fsanitize=address
ARFLAGS := -rcs

# ANSI color codes
GREEN := \033[0;32m
MAGENTA := \033[0;35m
BOLD := \033[1m
NC := \033[0m # Reset

all: $(NAME)

$(NAME): $(OBJS)
#$(AR) $(ARFLAGS) $(NAME) $(OBJS)
	$(CPP) $(LDFLAGS) $(OBJS) -o $(NAME)
	@echo "$(GREEN)$(BOLD)Successful Compilation$(NC)"

# Rule to compile .o files
$(OBJ_DIR)/%.o: %.c | $(OBJ_DIR)
	mkdir -p $(@D)
	$(CPP) $(CFLAGS) -c $< -o $@

# Ensure the directories exist
$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

clean:
	$(RM) $(OBJ_DIR)

fclean: clean
	$(RM) $(NAME)
	@echo "$(MAGENTA)$(BOLD)Executable + Object Files cleaned$(NC)"

re: fclean submodule_update all

submodule_update:
	git submodule update --remote --merge

san: fclean
	make CFLAGS="$(CFLAGS_SAN)" LDFLAGS="$(LDFLAGS_SAN)"
	@echo "$(GREEN)$(BOLD)Successful Compilation with fsan$(NC)"

re_sub: submodule_rebuild

submodule_rebuild:
	git submodule deinit -f .
	git submodule update --init --recursive

debug: clean
debug: CFLAGS += -DDEBUG
debug: $(NAME)

-include $(OBJS:%.o=%.d)

.PHONY: all clean fclean re re_sub submodule_rebuild san debug test test_cases
