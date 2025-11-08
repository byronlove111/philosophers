/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   cleanup.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: abbouras <abbouras@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/11/08 20:40:00 by abbouras          #+#    #+#             */
/*   Updated: 2025/11/08 22:11:52 by abbouras         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../include/philo.h"

/*
** Detruit tous les mutex et libere toute la memoire
*/
void	cleanup(t_data *data)
{
	int	i;

	if (data->forks)
	{
		i = 0;
		while (i < data->nb_philo)
		{
			pthread_mutex_destroy(&data->forks[i]);
			i++;
		}
		free(data->forks);
	}
	if (data->philos)
		free(data->philos);
	pthread_mutex_destroy(&data->print_mutex);
	pthread_mutex_destroy(&data->state_mutex);
}
