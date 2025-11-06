/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   atoi_strict.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: abbouras <abbouras@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/11/06 12:10:00 by abbouras          #+#    #+#             */
/*   Updated: 2025/11/06 12:29:52 by abbouras         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../include/philo.h"

int	ft_atoi_strict(char *str, int *result)
{
	if (!str || !result)
		return (-1);
	*result = 0;
	while ((9 <= *str && *str <= 13) || *str == ' ')
		str++;
	if (*str == '-')
		return (-1);
	if (*str == '+')
		str++;
	while (*str >= '0' && *str <= '9')
	{
		*result = *result * 10 + (*str - '0');
		str++;
	}
	if (*str != '\0' || *result <= 0)
		return (-1);
	return (0);
}
