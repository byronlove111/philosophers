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
** Valide qu'une string est un nombre positif valide
** Retourne 1 si valide, 0 sinon
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
** Convertit une string en int (atoi classique)
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
** Valide et convertit une string en int positif
** Retourne le nombre si valide, -1 si invalide
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
