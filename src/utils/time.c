/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   time.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: abbouras <abbouras@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/11/06 12:40:00 by abbouras          #+#    #+#             */
/*   Updated: 2025/11/08 22:10:13 by abbouras         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../include/philo.h"

/*
** Obtient le timestamp actuel en millisecondes
** Utilise gettimeofday() pour une precision microseconde
** Retourne le temps en ms depuis epoch
*/

long	get_time(void)
{
	struct timeval	tv;

	if (gettimeofday(&tv, NULL) == -1)
		return (-1);
	return ((tv.tv_sec * 1000) + (tv.tv_usec / 1000));
}

/*
** Calcule le temps ecoule depuis start_time
** Retourne la difference en millisecondes
*/

long	get_elapsed_time(long start_time)
{
	return (get_time() - start_time);
}

/*
** Sleep precis en millisecondes
** Evite les derives de usleep() en verifiant le temps reel
** Utilise des micro-sleeps pour plus de precision
*/

void	ft_usleep(long ms)
{
	long	start;
	long	elapsed;
	long	remaining;

	start = get_time();
	while (1)
	{
		elapsed = get_time() - start;
		remaining = ms - elapsed;
		if (remaining <= 0)
			break ;
		if (remaining > 1)
			usleep(500);
		else
			usleep(100);
	}
}
