/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   actions.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: abbouras <abbouras@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/11/08 20:22:16 by abbouras          #+#    #+#             */
/*   Updated: 2025/11/08 22:36:14 by abbouras         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../include/philo.h"

/*
** The philosopher thinks
*/
void	think(t_philo *philo)
{
	print_status(philo, "is thinking");
}

/*
** Takes both forks (locks the mutexes)
** Acquisition order by increasing index to avoid deadlocks
*/
void	take_forks(t_philo *philo)
{
	pthread_mutex_t	*first;
	pthread_mutex_t	*second;

	if (philo->left_fork < philo->right_fork)
	{
		first = philo->left_fork;
		second = philo->right_fork;
	}
	else
	{
		first = philo->right_fork;
		second = philo->left_fork;
	}
	pthread_mutex_lock(first);
	print_status(philo, "has taken a fork");
	pthread_mutex_lock(second);
	print_status(philo, "has taken a fork");
}

/*
** The philosopher eats
** Updates last_meal_time and meals_eaten (protected by mutex)
*/
void	eat(t_philo *philo)
{
	pthread_mutex_lock(&philo->data->state_mutex);
	philo->last_meal_time = get_time();
	philo->meals_eaten++;
	pthread_mutex_unlock(&philo->data->state_mutex);
	print_status(philo, "is eating");
	ft_usleep(philo->data->time_to_eat, philo->data);
}

/*
** Puts down both forks (unlocks the mutexes)
*/
void	drop_forks(t_philo *philo)
{
	pthread_mutex_unlock(philo->right_fork);
	pthread_mutex_unlock(philo->left_fork);
}

/*
** The philosopher sleeps
*/
void	philo_sleep(t_philo *philo)
{
	print_status(philo, "is sleeping");
	ft_usleep(philo->data->time_to_sleep, philo->data);
}
