# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: abbouras <abbouras@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/11/06 12:16:00 by abbouras          #+#    #+#              #
#    Updated: 2025/11/06 12:25:47 by abbouras         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME		= philo

CC			= cc
CFLAGS		= -Wall -Wextra -Werror -pthread
INCLUDES	= -I./include

SRC_DIR		= src
UTILS_DIR	= $(SRC_DIR)/utils
OBJ_DIR		= obj

SRCS		= $(SRC_DIR)/main.c \
			  $(SRC_DIR)/args.c \
			  $(UTILS_DIR)/atoi_strict.c \
			  $(UTILS_DIR)/error.c

OBJS		= $(SRCS:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(NAME)
	@echo "✓ $(NAME) compiled successfully"

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

clean:
	rm -rf $(OBJ_DIR)
	@echo "✓ Object files removed"

fclean: clean
	rm -f $(NAME)
	@echo "✓ $(NAME) removed"

re: fclean all

.PHONY: all clean fclean re

