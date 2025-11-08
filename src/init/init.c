/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   init.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: abbouras <abbouras@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/11/08 11:50:35 by abbouras          #+#    #+#             */
/*   Updated: 2025/11/08 20:14:51 by abbouras         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../include/philo.h"

/*
** Alloue et initialise les mutex des fourchettes
** En cas d'erreur, nettoie tout ce qui a ete cree
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
** Alloue et initialise le tableau de philosophes
** Assigne les fourchettes gauche/droite (table ronde)
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
** Detruit les mutex et libere la memoire en cas d'erreur
** forks_initialized: 1 si les forks existent, 0 sinon
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
	pthread_mutex_destroy(&data->death_mutex);
}

/*
** Initialise toutes les ressources de la simulation
** Flags -> Mutex -> Forks -> Philos
** En cas d'erreur, nettoie tout ce qui a ete cree
*/
int	init_data(t_data *data)
{
	data->someone_died = 0;
	data->all_ate_enough = 0;
	data->start_time = 0;
	if (pthread_mutex_init(&data->print_mutex, NULL) != 0)
		return (print_error(-1, "Failed to initialize print mutex"));
	if (pthread_mutex_init(&data->death_mutex, NULL) != 0)
	{
		pthread_mutex_destroy(&data->print_mutex);
		return (print_error(-1, "Failed to initialize death mutex"));
	}
	if (init_forks(data) != 0)
	{
		pthread_mutex_destroy(&data->print_mutex);
		pthread_mutex_destroy(&data->death_mutex);
		return (-1);
	}
	if (init_philos(data) != 0)
	{
		cleanup_init(data, 1);
		return (-1);
	}
	return (0);
}
