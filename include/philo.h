/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   philo.h                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: abbouras <abbouras@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/11/06 11:49:59 by abbouras          #+#    #+#             */
/*   Updated: 2025/11/08 21:42:57 by abbouras         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef PHILO_H
# define PHILO_H

# include <stdio.h>
# include <stdlib.h>
# include <unistd.h>
# include <pthread.h>
# include <sys/time.h>

typedef struct s_data	t_data;

/* Structure representing a philosopher */
typedef struct s_philo
{
	int					id;
	int					meals_eaten;
	long				last_meal_time;
	pthread_t			thread;
	pthread_mutex_t		*left_fork;
	pthread_mutex_t		*right_fork;
	t_data				*data;
}	t_philo;

/* Structure containing the config and state of the simulation */
typedef struct s_data
{
	int					nb_philo;
	long				time_to_die;
	long				time_to_eat;
	long				time_to_sleep;
	int					must_eat_count;
	pthread_mutex_t		*forks;
	t_philo				*philos;
	pthread_t			monitor;
	long				start_time;
	int					someone_died;
	int					all_ate_enough;
	pthread_mutex_t		print_mutex;
	pthread_mutex_t		state_mutex;
}	t_data;

int		parse_args(int argc, char **argv, t_data *data);
int		ft_atoi_strict(char *str);
int		print_error(int error_code, char *msg);
long	get_time(void);
long	get_elapsed_time(long start_time);
void	ft_usleep(long ms);
int		init_data(t_data *data);
void	print_status(t_philo *philo, char *status);
void	think(t_philo *philo);
void	take_forks(t_philo *philo);
void	eat(t_philo *philo);
void	drop_forks(t_philo *philo);
void	philo_sleep(t_philo *philo);
void	*philo_routine(void *arg);
void	*philo_routine_single(void *arg);
void	*monitor_routine(void *arg);
int		start_simulation(t_data *data);
void	cleanup(t_data *data);
#endif