/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   time.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: abbouras <abbouras@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/11/06 12:40:00 by abbouras          #+#    #+#             */
/*   Updated: 2025/11/09 11:06:17 by abbouras         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../include/philo.h"

/*
** Gets the current timestamp in milliseconds
** Uses gettimeofday() for microsecond precision
** Returns the time in ms since epoch
*/

long	get_time(void)
{
	struct timeval	tv;

	if (gettimeofday(&tv, NULL) == -1)
		return (-1);
	return ((tv.tv_sec * 1000) + (tv.tv_usec / 1000));
}

/*
** Calculates the elapsed time since start_time
** Returns the difference in milliseconds
*/

long	get_elapsed_time(long start_time)
{
	return (get_time() - start_time);
}

/*
** Precise sleep in milliseconds
** Avoids usleep() drift by checking real time
** Uses micro-sleeps for better precision
** Can be interrupted if someone died
*/

void	ft_usleep(long ms, t_data *data)
{
	long	start;
	long	elapsed;
	long	remaining;
	int		stop;

	start = get_time();
	while (1)
	{
		elapsed = get_time() - start;
		remaining = ms - elapsed;
		if (remaining <= 0)
			break ;
		if (data)
		{
			pthread_mutex_lock(&data->state_mutex);
			stop = data->someone_died || data->all_ate_enough;
			pthread_mutex_unlock(&data->state_mutex);
			if (stop)
				break ;
		}
		if (remaining > 1)
			usleep(500);
		else
			usleep(100);
	}
}
