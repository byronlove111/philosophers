/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   args.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: abbouras <abbouras@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/11/06 12:05:00 by abbouras          #+#    #+#             */
/*   Updated: 2025/11/08 20:21:08 by abbouras         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../include/philo.h"

/*
** Parses and assigns program arguments to the data structure
** Arguments: nb_philo time_to_die time_to_eat time_to_sleep [must_eat_count]
** Returns 0 on success, -1 on error
*/
int	parse_args(int argc, char **argv, t_data *data)
{
	if (argc != 5 && argc != 6)
		return (print_error(-1, "Invalid number of arguments"));
	data->nb_philo = ft_atoi_strict(argv[1]);
	if (data->nb_philo == -1)
		return (print_error(-1, "Invalid number of philosophers"));
	data->time_to_die = ft_atoi_strict(argv[2]);
	if (data->time_to_die == -1)
		return (print_error(-1, "Invalid time to die"));
	data->time_to_eat = ft_atoi_strict(argv[3]);
	if (data->time_to_eat == -1)
		return (print_error(-1, "Invalid time to eat"));
	data->time_to_sleep = ft_atoi_strict(argv[4]);
	if (data->time_to_sleep == -1)
		return (print_error(-1, "Invalid time to sleep"));
	if (argc == 6)
	{
		data->must_eat_count = ft_atoi_strict(argv[5]);
		if (data->must_eat_count == -1)
			return (print_error(-1, "Invalid number of meals"));
	}
	else
		data->must_eat_count = -1;
	return (0);
}
