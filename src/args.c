/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   args.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: abbouras <abbouras@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/11/06 12:05:00 by abbouras          #+#    #+#             */
/*   Updated: 2025/11/06 12:37:28 by abbouras         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../include/philo.h"

/*
** Valide et parse les arguments du programme
** Arguments: nb_philo time_to_die time_to_eat time_to_sleep [must_eat_count]
** Retourne 0 en succes, -1 en erreur
*/
int	validate_args(int argc, char **argv, t_data *data)
{
	int	temp;

	if (argc != 5 && argc != 6)
		return (print_error(-1, "Invalid number of arguments"));
	if (ft_atoi_strict(argv[1], &data->nb_philo) != 0)
		return (print_error(-1, "Invalid number of philosophers"));
	if (ft_atoi_strict(argv[2], &temp) != 0)
		return (print_error(-1, "Invalid time to die"));
	data->time_to_die = temp;
	if (ft_atoi_strict(argv[3], &temp) != 0)
		return (print_error(-1, "Invalid time to eat"));
	data->time_to_eat = temp;
	if (ft_atoi_strict(argv[4], &temp) != 0)
		return (print_error(-1, "Invalid time to sleep"));
	data->time_to_sleep = temp;
	if (argc == 6)
	{
		if (ft_atoi_strict(argv[5], &data->must_eat_count) != 0)
			return (print_error(-1, "Invalid number of meals"));
	}
	else
		data->must_eat_count = -1;
	return (0);
}
