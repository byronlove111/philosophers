/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   error.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: abbouras <abbouras@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/11/06 12:10:00 by abbouras          #+#    #+#             */
/*   Updated: 2025/11/06 12:29:40 by abbouras         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../include/philo.h"

int	print_error(int error_code, char *msg)
{
	int	i;

	i = 0;
	while (msg[i])
		i++;
	write(2, "Error: ", 7);
	write(2, msg, i);
	write(2, "\n", 1);
	return (error_code);
}
