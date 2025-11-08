/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   monitor.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: abbouras <abbouras@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/11/08 21:30:00 by abbouras          #+#    #+#             */
/*   Updated: 2025/11/08 21:35:36 by abbouras         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../include/philo.h"

/*
** Verifie si la simulation doit s'arreter
** Protege par mutex pour eviter les data races
*/
static int	is_simulation_ended(t_data *data)
{
	int	ended;

	pthread_mutex_lock(&data->state_mutex);
	ended = data->someone_died || data->all_ate_enough;
	pthread_mutex_unlock(&data->state_mutex);
	return (ended);
}

/*
** Verifie si tous les philosophes ont mange must_eat_count fois
** Retourne 1 si oui, 0 sinon
*/
static int	check_all_ate_enough(t_data *data)
{
	int	i;
	int	all_done;

	if (data->must_eat_count == -1)
		return (0);
	pthread_mutex_lock(&data->state_mutex);
	all_done = 1;
	i = 0;
	while (i < data->nb_philo)
	{
		if (data->philos[i].meals_eaten < data->must_eat_count)
		{
			all_done = 0;
			break ;
		}
		i++;
	}
	pthread_mutex_unlock(&data->state_mutex);
	return (all_done);
}

/*
** Verifie si un philosophe est mort
** Retourne 1 si mort detectee, 0 sinon
*/
static int	check_death(t_data *data)
{
	int		i;
	long	current_time;
	long	time_since_meal;

	i = 0;
	while (i < data->nb_philo)
	{
		pthread_mutex_lock(&data->state_mutex);
		current_time = get_time();
		time_since_meal = current_time - data->philos[i].last_meal_time;
		if (time_since_meal > data->time_to_die)
		{
			pthread_mutex_lock(&data->print_mutex);
			data->someone_died = 1;
			printf("%ld %d died\n",
				get_elapsed_time(data->start_time), data->philos[i].id);
			pthread_mutex_unlock(&data->print_mutex);
			pthread_mutex_unlock(&data->state_mutex);
			return (1);
		}
		pthread_mutex_unlock(&data->state_mutex);
		i++;
	}
	return (0);
}

/*
** Routine du thread monitor
** Surveille en permanence les philosophes
*/
void	*monitor_routine(void *arg)
{
	t_data	*data;

	data = (t_data *)arg;
	while (!is_simulation_ended(data))
	{
		if (check_death(data))
			break ;
		if (check_all_ate_enough(data))
		{
			pthread_mutex_lock(&data->state_mutex);
			data->all_ate_enough = 1;
			pthread_mutex_unlock(&data->state_mutex);
			break ;
		}
		ft_usleep(1);
	}
	return (NULL);
}
