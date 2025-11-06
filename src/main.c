/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: abbouras <abbouras@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/11/06 12:16:00 by abbouras          #+#    #+#             */
/*   Updated: 2025/11/06 12:36:34 by abbouras         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../include/philo.h"

int	main(int argc, char **argv)
{
	t_data	data;
	int		ret;

	ret = validate_args(argc, argv, &data);
	if (ret < 0)
		return (1);
	printf("✓ Arguments valides!\n");
	printf("  nb_philo: %d\n", data.nb_philo);
	printf("  time_to_die: %ld ms\n", data.time_to_die);
	printf("  time_to_eat: %ld ms\n", data.time_to_eat);
	printf("  time_to_sleep: %ld ms\n", data.time_to_sleep);
	if (data.must_eat_count != -1)
		printf("  must_eat_count: %d\n", data.must_eat_count);
	else
		printf("  must_eat_count: non specifie\n");
	return (0);
}
