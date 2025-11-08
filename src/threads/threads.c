/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   threads.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: abbouras <abbouras@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/11/08 21:40:45 by abbouras          #+#    #+#             */
/*   Updated: 2025/11/08 21:42:57 by abbouras         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../include/philo.h"

/*
** Attend que tous les threads se terminent
*/
static void	join_threads(t_data *data)
{
	int	i;

	i = 0;
	while (i < data->nb_philo)
	{
		pthread_join(data->philos[i].thread, NULL);
		i++;
	}
	pthread_join(data->monitor, NULL);
}

/*
** Cree les threads philosophes
*/
static int	create_philo_threads(t_data *data)
{
	int	i;

	i = 0;
	while (i < data->nb_philo)
	{
		if (pthread_create(&data->philos[i].thread, NULL,
				philo_routine, &data->philos[i]) != 0)
			return (print_error(-1, "Failed to create philosopher thread"));
		i++;
	}
	return (0);
}

/*
** Cas special : 1 seul philosophe
** Il prend une fourchette et meurt
*/
static int	handle_single_philo(t_data *data)
{
	if (pthread_create(&data->philos[0].thread, NULL,
			philo_routine_single, &data->philos[0]) != 0)
		return (print_error(-1, "Failed to create philosopher thread"));
	if (pthread_create(&data->monitor, NULL, monitor_routine, data) != 0)
		return (print_error(-1, "Failed to create monitor thread"));
	join_threads(data);
	return (0);
}

/*
** Lance la simulation
** Initialise start_time, cree les threads, attend la fin
*/
int	start_simulation(t_data *data)
{
	int	i;

	data->start_time = get_time();
	i = 0;
	while (i < data->nb_philo)
	{
		data->philos[i].last_meal_time = data->start_time;
		i++;
	}
	if (data->nb_philo == 1)
		return (handle_single_philo(data));
	if (create_philo_threads(data) != 0)
		return (-1);
	if (pthread_create(&data->monitor, NULL, monitor_routine, data) != 0)
		return (print_error(-1, "Failed to create monitor thread"));
	join_threads(data);
	return (0);
}
