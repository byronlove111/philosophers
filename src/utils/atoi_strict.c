/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   atoi_strict.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: abbouras <abbouras@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/11/06 12:10:00 by abbouras          #+#    #+#             */
/*   Updated: 2025/11/08 17:44:49 by abbouras         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../include/philo.h"

/*
** Validates that a string is a valid positive number
** Returns 1 if valid, 0 otherwise
*/
static int	is_valid_positive_number(char *str)
{
	int	i;

	if (!str || !*str)
		return (0);
	i = 0;
	while ((9 <= str[i] && str[i] <= 13) || str[i] == ' ')
		i++;
	if (str[i] == '-')
		return (0);
	if (str[i] == '+')
		i++;
	if (str[i] < '0' || str[i] > '9')
		return (0);
	while (str[i] >= '0' && str[i] <= '9')
		i++;
	if (str[i] != '\0')
		return (0);
	return (1);
}

/*
** Converts a string to int (classic atoi)
*/
static int	ft_atoi(char *str)
{
	int	result;
	int	i;

	result = 0;
	i = 0;
	while ((9 <= str[i] && str[i] <= 13) || str[i] == ' ')
		i++;
	if (str[i] == '+')
		i++;
	while (str[i] >= '0' && str[i] <= '9')
	{
		result = result * 10 + (str[i] - '0');
		i++;
	}
	return (result);
}

/*
** Validates and converts a string to a positive int
** Returns the number if valid, -1 if invalid
*/
int	ft_atoi_strict(char *str)
{
	int	result;

	if (!is_valid_positive_number(str))
		return (-1);
	result = ft_atoi(str);
	if (result <= 0)
		return (-1);
	return (result);
}
