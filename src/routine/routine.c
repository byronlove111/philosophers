/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   routine.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: abbouras <abbouras@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/11/08 20:22:12 by abbouras          #+#    #+#             */
/*   Updated: 2025/11/08 21:51:28 by abbouras         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../include/philo.h"

/*
** Verifie si la simulation doit s'arreter
** Protege par mutex pour eviter les data races
*/
static int	should_stop(t_philo *philo)
{
	int	stop;

	pthread_mutex_lock(&philo->data->state_mutex);
	stop = philo->data->someone_died || philo->data->all_ate_enough;
	pthread_mutex_unlock(&philo->data->state_mutex);
	return (stop);
}

/*
** Routine speciale pour un seul philosophe
** Il ne peut pas manger (une seule fourchette) donc il meurt
*/
void	*philo_routine_single(void *arg)
{
	t_philo	*philo;

	philo = (t_philo *)arg;
	pthread_mutex_lock(philo->left_fork);
	print_status(philo, "has taken a fork");
	ft_usleep(philo->data->time_to_die);
	pthread_mutex_unlock(philo->left_fork);
	return (NULL);
}

/*
** Routine principale d'un philosophe
** Cycle: penser -> manger -> dormir
** Continue jusqu'a ce que someone_died ou all_ate_enough soit vrai
*/
void	*philo_routine(void *arg)
{
	t_philo	*philo;

	philo = (t_philo *)arg;
	if (philo->id % 2 == 0)
		ft_usleep(1);
	while (!should_stop(philo))
	{
		think(philo);
		take_forks(philo);
		eat(philo);
		drop_forks(philo);
		philo_sleep(philo);
	}
	return (NULL);
}
