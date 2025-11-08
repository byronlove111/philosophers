/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   init.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: abbouras <abbouras@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/11/08 11:50:35 by abbouras          #+#    #+#             */
/*   Updated: 2025/11/08 21:32:57 by abbouras         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../include/philo.h"

/*
** Allocates and initializes fork mutexes
** On error, cleans up everything that was created
*/
static int	init_forks(t_data *data)
{
	int	i;

	data->forks = malloc(sizeof(pthread_mutex_t) * data->nb_philo);
	if (!data->forks)
		return (print_error(-1, "Failed to allocate forks"));
	i = 0;
	while (i < data->nb_philo)
	{
		if (pthread_mutex_init(&data->forks[i], NULL) != 0)
		{
			while (--i >= 0)
				pthread_mutex_destroy(&data->forks[i]);
			free(data->forks);
			return (print_error(-1, "Failed to initialize fork mutex"));
		}
		i++;
	}
	return (0);
}

/*
** Allocates and initializes the philosopher array
** Assigns left/right forks (round table)
*/
static int	init_philos(t_data *data)
{
	int	i;

	data->philos = malloc(sizeof(t_philo) * data->nb_philo);
	if (!data->philos)
		return (print_error(-1, "Failed to allocate philosophers"));
	i = 0;
	while (i < data->nb_philo)
	{
		data->philos[i].id = i + 1;
		data->philos[i].meals_eaten = 0;
		data->philos[i].last_meal_time = 0;
		data->philos[i].left_fork = &data->forks[i];
		if (i == data->nb_philo - 1)
			data->philos[i].right_fork = &data->forks[0];
		else
			data->philos[i].right_fork = &data->forks[i + 1];
		data->philos[i].data = data;
		i++;
	}
	return (0);
}

/*
** Destroys mutexes and frees memory on error
** forks_initialized: 1 if forks exist, 0 otherwise
*/
static void	cleanup_init(t_data *data, int forks_initialized)
{
	int	i;

	if (forks_initialized)
	{
		i = 0;
		while (i < data->nb_philo)
		{
			pthread_mutex_destroy(&data->forks[i]);
			i++;
		}
		free(data->forks);
	}
	pthread_mutex_destroy(&data->print_mutex);
	pthread_mutex_destroy(&data->state_mutex);
}

/*
** Initializes all simulation resources
** Flags -> Mutex -> Forks -> Philos
** On error, cleans up everything that was created
*/
int	init_data(t_data *data)
{
	data->someone_died = 0;
	data->all_ate_enough = 0;
	data->start_time = 0;
	if (pthread_mutex_init(&data->print_mutex, NULL) != 0)
		return (print_error(-1, "Failed to initialize print mutex"));
	if (pthread_mutex_init(&data->state_mutex, NULL) != 0)
	{
		pthread_mutex_destroy(&data->print_mutex);
		return (print_error(-1, "Failed to initialize state mutex"));
	}
	if (init_forks(data) != 0)
	{
		pthread_mutex_destroy(&data->print_mutex);
		pthread_mutex_destroy(&data->state_mutex);
		return (-1);
	}
	if (init_philos(data) != 0)
	{
		cleanup_init(data, 1);
		return (-1);
	}
	return (0);
}
