/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   routine.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: abbouras <abbouras@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/11/08 20:22:12 by abbouras          #+#    #+#             */
/*   Updated: 2025/11/09 12:17:31 by abbouras         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../include/philo.h"

/*
** Checks if the simulation should stop
** Protected by mutex to avoid data races
*/
static int	should_stop(t_philo *philo)
{
	int	stop;

	pthread_mutex_lock(&philo->data->state_mutex);
	if (philo->data->someone_died)
		stop = 1;
	else if (philo->data->all_ate_enough)
		stop = 1;
	else
		stop = 0;
	pthread_mutex_unlock(&philo->data->state_mutex);
	return (stop);
}

/*
** Checks if this philosopher has eaten enough times
** Returns 1 if yes, 0 if no or if must_eat_count is not set
*/
static int	has_eaten_enough(t_philo *philo)
{
	int	enough;

	if (philo->data->must_eat_count == -1)
		return (0);
	pthread_mutex_lock(&philo->data->state_mutex);
	enough = (philo->meals_eaten >= philo->data->must_eat_count);
	pthread_mutex_unlock(&philo->data->state_mutex);
	return (enough);
}

/*
** Special routine for a single philosopher
** Cannot eat (only one fork) so dies
*/
void	*philo_routine_single(void *arg)
{
	t_philo	*philo;

	philo = (t_philo *)arg;
	pthread_mutex_lock(philo->left_fork);
	print_status(philo, "has taken a fork");
	ft_usleep(philo->data->time_to_die, philo->data);
	pthread_mutex_unlock(philo->left_fork);
	return (NULL);
}

/*
** Main routine of a philosopher
** Cycle: think -> eat -> sleep
** Continues until someone_died or all_ate_enough is true
*/
void	*philo_routine(void *arg)
{
	t_philo	*philo;

	philo = (t_philo *)arg;
	if (philo->id % 2 == 0)
		ft_usleep(1, philo->data);
	while (!should_stop(philo))
	{
		if (has_eaten_enough(philo))
			break ;
		think(philo);
		take_forks(philo);
		eat(philo);
		drop_forks(philo);
		philo_sleep(philo);
	}
	return (NULL);
}
